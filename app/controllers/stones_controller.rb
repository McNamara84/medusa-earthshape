class StonesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :download_card, :download_bundle_card, :download_label, :download_bundle_label]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource

  def index
    @search = Stone.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @stones = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @stones
  end

  def show
    daughterattribs=@stone.attributes.merge(:id=>nil,:igsn=>nil,:parent_id=>nil)
   @daughter = Stone.new(daughterattribs)
    @daughterproperties=RecordProperty.where(datum_id: @stone.id , datum_type:"Stone").take
    respond_with @stone
  end

  def edit
    respond_with @stone, layout: !request.xhr?
  end

  def create
    @stone = Stone.new(stone_params)
    @stone.save
    respond_with @stone
  end

  def update
    @stone.update_attributes(stone_params)
    respond_with @stone
  end
  
  def destroy
    @stone.destroy
    respond_with @stone
  end

  def family
    respond_with @stone, layout: !request.xhr?
  end

  def picture
    respond_with @stone, layout: !request.xhr?
  end

  def map
    respond_with @stone, layout: !request.xhr?
  end

  def property
    respond_with @stone, layout: !request.xhr?
  end

  def bundle_edit
    respond_with @stones
  end

  def bundle_update
    @stones.each { |stone| stone.update_attributes(stone_params.only_presence) }
    render :bundle_edit
  end

  def igsn_register
    igsn=IgsnHelper::Igsn.new(:user =>"user", :password=>"secret", :endpoint=>'https://doidb.wdc-terra.org/igsn')
    stone=Stone.find(params[:id])
    
    igsn.mint(@stone.igsn,"http://url?igsn="+@stone.igsn.sub('10273/TEST/',''))
    igsn.upload_metadata(genmetadata)

    redirect_to stone_url(@stone)	  
   end

  def download_card
    stone = Stone.find(params[:id])
    #create IGSN on behalf of the owner if  not yet assigned
    
    if stone.user.prefix.present?
    
	    if stone.igsn.blank? 
		    stone.create_igsn(stone.user.prefix, stone) 
		    stone.save
	    end
	    report= Stone.find(params[:id]).build_igsn_card
	    send_data(report.generate, filename: "sample.pdf", type: "application/pdf")
    else
	    sample_owner_without_igsn_prefix
    end
  end

  def igsn_create
    stone = Stone.find(params[:id])
    #create IGSN on behalf of the owner if  not yet assigned   
    if stone.user.prefix.present?    
	    if stone.igsn.blank? 
		    stone.create_igsn(stone.user.prefix, stone) 
		    stone.save
	    end
	    redirect_to stone_url(@stone)
    else
	    sample_owner_without_igsn_prefix
    end
  end


  def download_bundle_card
    method = (params[:a4] == "true") ? :build_a_four : :build_cards
    report = Stone.send(method, @stones)
    send_data(report.generate, filename: "samples.pdf", type: "application/pdf")
  end

  def download_label
    stone = Stone.find(params[:id])
    send_data(stone.build_label, filename: "sample_#{stone.name}.csv", type: "text/csv")
  end

  def download_bundle_label
    label = Stone.build_bundle_label(@stones)
    send_data(label, filename: "samples.csv", type: "text/csv")
  end

  private


  def sample_owner_without_igsn_prefix
    respond_to do |format|
      format.html { render "parts/sample_owner_without_igsn_prefix", status: :unprocessable_entity }
      format.all { render nothing: true, status: :unprocessable_entity }
    end
  end



  def stone_params
    params.require(:stone).permit(
      :name,
      :physical_form_id,
      :classification_id,
      :quantity, 
      :quantityunit_id,
      :tag_list,
      :parent_global_id,
      :parent_id,
      :box_global_id,
      :box_id,
      :place_global_id,
      :place_id,
      :description,
      :user_id,
      :group_id,
      :published,
      :quantity_initial,     
      :igsn,     
      :labname,
      :collection_global_id,
      :collection_id,      
      :collectionmethod_id,       
      :stonecontainer_type_id,
      :date,
      :sampledepth,
      record_property_attributes: [
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable
      ],
      collectors_attributes: [
        :id,
        :name,
        :affiliation,
	:_destroy
	]
    )
  end

  def find_resource
    @stone = Stone.find(params[:id]).decorate
  end

  def find_resources
    @stones = Stone.where(id: params[:ids])
  end

def genmetadata
	
	igsn=@stone.igsn.sub('10273/TEST/','')
	parentigsn=niltostring(@stone.try(:parent).try(:igsn)).sub('10273/TEST/','')
	
	material = niltostring(@stone.try(:classification).try(:parent).try(:parent).try(:name)).to_s
	classification = niltostring(@stone.try(:classification).try(:parent).try(:name)).to_s
	type = niltostring(@stone.try(:classification).try(:name)).to_s
	
	if material.blank?
		material=classification
		classification=type
		type=''		
	end
	if material.blank?
		material=classification
		classification=''
	end
	
	latitude=@stone.try(:place).try(:latitude);
	longitude=@stone.try(:place).try(:longitude)
	country=""
	province=""	
	if  !( latitude.blank? || longitude.blank?)
	 country_subdivisions = Geonames::WebService.country_subdivision "%0.2f" % latitude, "%0.2f" % longitude
	 country=country_subdivisions[0].country_name
	 province=country_subdivisions[0].admin_name_1
	end
 
	prepstring=""
 	Preparation.where(stone_id: @stone.id).find_each do |prep|
		prepstring+='<description descriptionScheme="Preparation">'+prep.preparation_type.name 
		if !prep.info.blank?
			prepstring+=" ("+prep.info+")"
		end
		prepstring+='</description>'
	end
	
	bibstring=""
	Referring.where(referable_id:@stone.id, referable_type: "Stone").each do |bibref|
		bibitem=Bib.where(id: bibref.bib_id).take
		if !bibitem.try(:doi).blank?
			bibstring+='<relatedIdentifier relatedIdentifierType="DOI" relationType="isCitedBy">'+bibitem.doi+'</relatedIdentifier>'		
		end
	end
	
	

	
	return '<?xml version="1.0" encoding="UTF-8"?>
	<samples xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://doidb.wdc-terra.org/igsnaa http://doidb.wdc-terra.org/igsnaa/doidb.wdc-terra.org/igsnaa/0.1/samplev2.xsd">
	<sample>
	<user_code>'+niltostring(@stone.try(:collection).try(:project))+'</user_code>
	<sample_type>Core Sample</sample_type>
	<name>'+@stone.name+'</name>
	<igsn>'+igsn+'</igsn>
	<parent_igsn>'+parentigsn+'</parent_igsn>
	<is_private>0</is_private>
	<sample_request></sample_request>
	<sampled_by></sampled_by>
	<sample_purpose></sample_purpose>
	<publish_date></publish_date>
	<latitude>'+niltostring(@stone.try(:place).try(:latitude)).to_s+'</latitude>
	<longitude>'+niltostring(@stone.try(:place).try(:longitude)).to_s+'</longitude>
	<coordinate_system>WGS84</coordinate_system>
	<elevation>'+niltostring(@stone.try(:place).try(:elevation)).to_s+'</elevation>
	<elevation_end></elevation_end>
	<elevation_unit>m</elevation_unit>
	<elevation_end_unit>m</elevation_end_unit>
	<primary_location_type>'+niltostring(@stone.try(:place).try(:landuse)).to_s+'</primary_location_type>
	<primary_location_name>'+niltostring(@stone.try(:place).try(:slope_description)).to_s+'</primary_location_name>
	<location_description>'+niltostring(@stone.try(:place).try(:description)).to_s+'</location_description>
	<locality/>
	<locality_description/>
	<country>'+country+'</country>
	<province>'+province+'</province>
	<county/>
	<city></city>
	<material>'+material+'</material>
	<classification>'+classification+'</classification>
	<field_name>'+type+'</field_name>
	<depth_min>'+niltostring(@stone.try(:collection).try(:depth_min)).to_s+'</depth_min>
	<depth_max>'+niltostring(@stone.try(:collection).try(:depth_max)).to_s+'</depth_max>
	<depth_scale>'+niltostring(@stone.try(:collection).try(:depth_unit))+'</depth_scale>
	<size>'+niltostring(@stone.quantity).to_s+'</size>
	<size_unit>'+niltostring(@stone.quantity_unit)+'</size_unit>
	<!--age_min></age_min>
	<age_max></age_max-->
	<age_unit/>
	<geological_age></geological_age>
	<geological_unit/>
	<descriptions>
	<description>'+niltostring(@stone.description)+'</description>'+prepstring+'
	</descriptions>
	<sample_image></sample_image>
	<sample_image_path></sample_image_path>
	<collection_method>'+niltostring(@stone.try(:collection).try(:collectionmethod).try(:name))+'</collection_method>
	<collection_method_descr></collection_method_descr>
	<length></length>
	<length_unit></length_unit>
	<cruise_field_prgrm>'+niltostring(@stone.try(:collection).try(:name))+'</cruise_field_prgrm>
	<platform_type></platform_type>
	<platform_name></platform_name>
	<platform_descr></platform_descr>
	<operator></operator>
	<operator></operator>
	<funding_agency></funding_agency>
	<collector>'+niltostring(@stone.try(:collection).try(:collector))+'/'+niltostring(@stone.try(:collection).try(:affiliation))+'</collector>
	<collection_start_date>'+niltostring(@stone.try(:collection).try(:collection_start)).to_s+'</collection_start_date>
	<collection_end_date>'+niltostring(@stone.try(:collection).try(:collection_end)).to_s+'</collection_end_date>
	<collection_date_precision>day</collection_date_precision>
	<current_archive>'+niltostring(@stone.labname)+'</current_archive>
	<current_archive_contact></current_archive_contact>
	<original_archive/>
	<original_archive_contact/>
	<launch_platform_name/>
	<relatedIdentifiers>
	'+bibstring+'
	</relatedIdentifiers>
	</sample></samples>'

end

def niltostring(str)
	
	return str.blank? ? '' : str 
end

end
