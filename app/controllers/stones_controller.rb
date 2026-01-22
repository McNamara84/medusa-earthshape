class StonesController < ApplicationController
  respond_to :html, :xml, :json, :pml, :modal
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :download_card, :download_bundle_card, :download_label, :download_bundle_label]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource
  before_action :decorate_resource, only: [:show, :edit, :family, :picture, :map, :property]

  def index
    @search = Stone.readables(current_user).ransack(params[:q]&.permit! || {})
    @search.sorts = ["updated_at DESC"] if @search.sorts.empty?
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
    @stone.update(stone_params)
    respond_with(@stone)
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
    @stones.each { |stone| stone.update(stone_params.only_presence) }
    render :bundle_edit
  end

  def igsn_register
    logger.info "=== IGSN REGISTER START ==="
    logger.info "User: #{current_user.try(:email)} (admin: #{current_user.try(:admin?)})"
    
    unless current_user.admin?
      logger.warn "IGSN Register: User is not admin, aborting"
      flash[:error] = "Only administrators can register IGSNs"
      redirect_to stone_url(@stone)
      return
    end

    begin
      # Check environment variables
      logger.info "IGSN_USER present: #{ENV['IGSN_USER'].present?}"
      logger.info "IGSN_PASSWORD present: #{ENV['IGSN_PASSWORD'].present?}"
      logger.info "IGSN_ENDPOINT: #{ENV.fetch('IGSN_ENDPOINT', 'https://doidb.wdc-terra.org/igsnaa')}"
      
      igsn = IgsnHelper::Igsn.new(
        :user => ENV.fetch('IGSN_USER'),
        :password => ENV.fetch('IGSN_PASSWORD'),
        :endpoint => ENV.fetch('IGSN_ENDPOINT', 'https://doidb.wdc-terra.org/igsnaa')
      )
      logger.info "IGSN Helper initialized successfully"
      
      stone = Stone.find(params[:id])
      logger.info "Stone found: #{stone.id} - #{stone.name} - IGSN: #{stone.igsn}"

      igsnparents = Array.new

      begin 
        logger.info "Processing stone: #{stone.id} with IGSN: #{stone.igsn}"
        igsnparents << {stone: stone, igsn: stone.igsn, regmetadata: genregmetadata(stone), metadata: genmetadata(stone)}
        stone = stone.parent
      end while stone

      igsnsample = igsnparents.shift
      logger.info "Main sample IGSN: #{igsnsample[:igsn]}"
      logger.info "Parent samples count: #{igsnparents.count}"

      # Register parents
      igsnparents.reverse_each do |parent_stone|
        begin
          logger.info "Looking up parent IGSN #{parent_stone[:igsn]}..."
          igsn.resolve(parent_stone[:igsn])
          logger.info "...found #{parent_stone[:igsn]}"
        rescue RestClient::ResourceNotFound => err
          logger.info "Registering parent #{parent_stone[:igsn]}"
          igsn.mint(parent_stone[:igsn], "http://dataservices.gfz-potsdam.de/igsn/esg/index.php?igsn=#{parent_stone[:igsn]}")
          igsn.upload_regmetadata(parent_stone[:regmetadata])
          igsn.upload_metadata(parent_stone[:igsn], parent_stone[:metadata])
        rescue => e
          logger.error "Error processing parent IGSN #{parent_stone[:igsn]}: #{e.class} - #{e.message}"
          logger.error e.backtrace.first(10).join("\n")
          raise e
        end
      end

      # Register requested sample
      logger.info "Registering main sample IGSN: #{igsnsample[:igsn]}"
      igsn.mint(igsnsample[:igsn], "http://dataservices.gfz-potsdam.de/igsn/esg/index.php?igsn=#{igsnsample[:igsn]}")

      begin
        igsn.upload_regmetadata(igsnsample[:regmetadata])
        igsn.upload_metadata(igsnsample[:igsn], igsnsample[:metadata])
      rescue => e
        logger.warn "First metadata upload order failed, trying reverse: #{e.message}"
        igsn.upload_metadata(igsnsample[:igsn], igsnsample[:metadata])
        igsn.upload_regmetadata(igsnsample[:regmetadata])
      end

      logger.info "IGSN registration successful, updating Solr..."
      
      # Solr update - use env vars if available
      solr_user = ENV.fetch('SOLR_USER', 'user')
      solr_password = ENV.fetch('SOLR_PASSWORD', 'secret')
      solr = SolrHelper::Solr.new(:user => solr_user, :password => solr_password)
      solr.deltaupdate
      
      logger.info "=== IGSN REGISTER COMPLETE ==="
      flash[:notice] = "IGSN #{igsnsample[:igsn]} registered successfully"
      
    rescue KeyError => e
      logger.error "IGSN Register: Missing environment variable: #{e.message}"
      flash[:error] = "IGSN configuration error: Missing #{e.message}"
    rescue RestClient::Unauthorized => e
      logger.error "IGSN Register: Authentication failed: #{e.message}"
      flash[:error] = "IGSN authentication failed. Please check credentials."
    rescue RestClient::Exception => e
      logger.error "IGSN Register: REST API error: #{e.class} - #{e.message}"
      logger.error "Response body: #{e.response.body}" if e.response
      flash[:error] = "IGSN API error: #{e.message}"
    rescue => e
      logger.error "IGSN Register: Unexpected error: #{e.class} - #{e.message}"
      logger.error e.backtrace.first(15).join("\n")
      flash[:error] = "IGSN registration failed: #{e.message}"
    end

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
  
    @stones.each do |stone|
        if stone.user.prefix.present?    
	    if stone.igsn.blank? 
		    stone.create_igsn(stone.user.prefix, stone) 
		    stone.save
	    end
         else
	    sample_owner_without_igsn_prefix
        end
    end
    
    method = (params[:a4] == "true") ? :build_igsn_a_four : :build_igsn_cards
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
      format.all { head :unprocessable_entity }
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
      :analysis_global_id,
      :attachment_file_global_id,
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
    @stone = Stone.find(params[:id])
  end

  def decorate_resource
    @stone = @stone.decorate if @stone
  end

  def find_resources
    @stones = Stone.where(id: params[:ids])
  end

def genregmetadata(stone)

relatedidentifiers=''

if stone.parent && stone.parent.igsn
  relatedidentifiers='<relatedResourceIdentifiers><relatedIdentifier relatedIdentifierType="handle" relationType="IsPartOf">10273/'+stone.parent.igsn+'</relatedIdentifier></relatedResourceIdentifiers>'
end

return '<?xml version="1.0" encoding="UTF-8"?>
<sample xmlns="http://igsn.org/schema/kernel-v.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://igsn.org/schema/kernel-v.1.0 http://doidb.wdc-terra.org/igsn/schemas/igsn.org/schema/1.0/igsn.xsd" >
<sampleNumber identifierType="igsn" >10273/'+stone.igsn+'</sampleNumber>
<registrant>
<registrantName>GFZ Data Services</registrantName>
</registrant>'+relatedidentifiers+'<log>
<logElement event="submitted" timeStamp="2017-05-30T00:00:33.237+02:00" ></logElement>
</log>
</sample> '

end

def genmetadata(stone)
	
	igsn=stone.igsn
	parentigsn=niltostring(stone.try(:parent).try(:igsn))

	building=niltostring(stone.box.get_building).encode(:xml => :text)

	material = niltostring(stone.classification.get_material)
	type=''
	classification=''

	if stone.classification.parent and stone.classification.parent.parent
		classification = niltostring(stone.try(:classification).try(:parent).try(:name)).to_s
		type = niltostring(stone.try(:classification).try(:name)).to_s
        elsif stone.classification.parent
	        classification = niltostring(stone.try(:classification).try(:name)).to_s
        end

	if material == 'rock'
		material = 'Rock'
		material_schema = 'http://vocabulary.odm2.org/medium/rock/'
	elsif material == 'gas'
		material = 'Gas'
                material_schema = 'http://vocabulary.odm2.org/medium/gas/'
	elsif material == 'vegetation' or material == 'fauna'
		material = 'Biology'
                material_schema = 'http://vocabulary.odm2.org/medium/organism/'
	elsif material == 'sediment'
		material = 'Sediment'
                material_schema = 'http://vocabulary.odm2.org/medium/sediment/'
	elsif material == 'soil'
		material = 'Soil'
                material_schema = 'http://vocabulary.odm2.org/medium/soil/'
	elsif material ==  'other'
		material = 'Other'
                material_schema = 'http://vocabulary.odm2.org/medium/other/'
	elsif material == 'water' and  classification == 'ice'
		material = 'Ice'
       	        material_schema = 'http://vocabulary.odm2.org/medium/ice/'
	elsif material == 'water'
		material = 'Liquid&gt;aqueous'
               	material_schema = 'http://vocabulary.odm2.org/medium/liquidAqueous/'
	end

	classification= niltostring(stone.try(:classification).try(:full_name)).to_s

	latitude=stone.try(:place).try(:latitude);
	longitude=stone.try(:place).try(:longitude)
	country=""
	province=""	
	if  !( latitude.blank? || longitude.blank?)
	 country_subdivisions = Geonames::WebService.country_subdivision "%0.2f" % latitude, "%0.2f" % longitude
         if !(country_subdivisions.empty?)
	   country=country_subdivisions[0].country_name
	   province=country_subdivisions[0].admin_name_1
	 end
	end
 
	prepstring=""
 	Preparation.where(stone_id: stone.id).find_each do |prep|
		prepstring+='<description descriptionScheme="Preparation">'+prep.preparation_type.name.encode(:xml => :text) 
		if !prep.info.blank?
			prepstring+=" ("+prep.info.encode(:xml => :text)+")"
		end
		prepstring+='</description>'
	end
	
	bibstring=""
	Referring.where(referable_id:stone.id, referable_type: "Stone").each do |bibref|
		bibitem=Bib.where(id: bibref.bib_id).take
		if !bibitem.try(:doi).blank?
			bibstring+='<relatedIdentifier relatedIdentifierType="DOI" relationType="isCitedBy">'+bibitem.doi+'</relatedIdentifier>'		
		end
	end
	
	

	
	return '<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns="http://pmd.gfz-potsdam.de/igsn/schemas/description/1.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://pmd.gfz-potsdam.de/igsn/schemas/description/1.3 http://pmd.gfz-potsdam.de/igsn/schemas/description/1.3/resource.xsd" type="Sample" >
<identifier type="IGSN" >'+stone.igsn+'</identifier>
<name>'+stone.name.encode(:xml => :text) +'</name>
<parentIdentifier type="IGSN" >'+niltostring(stone.try(:parent).try(:igsn))+'</parentIdentifier>
<registrant>
<name>GFZ Data Services</name>
<affiliation>
<name>GFZ Potsdam</name>
</affiliation>
</registrant>
<geoLocations>
<geoLocation>
<geometry type="Point" sridType="4326" >'+niltostring(stone.try(:place).try(:longitude)).to_s+' '+niltostring(stone.try(:place).try(:latitude)).to_s+'</geometry>
</geoLocation>
</geoLocations>
<resourceTypes>
<resourceType>http://vocabulary.odm2.org/samplingfeaturetype/specimen/</resourceType>
</resourceTypes>
<materials>
<material>'+material_schema+'</material>
</materials>
<collectionMethods>
<collectionMethod>Hand</collectionMethod>
</collectionMethods>
<sampleAccess>Public</sampleAccess>
<supplementalMetadata>
<record>
	<sample xmlns="http://pmd.gfz-potsdam.de/igsn/schemas/description-ext/1.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://pmd.gfz-potsdam.de/igsn/schemas/description-ext/1.3 http://pmd.gfz-potsdam.de/igsn/schemas/description-ext/1.3/sample.xsd">
	<user_code>'+niltostring(stone.try(:collection).try(:project))+'</user_code>
	<sample_type>Specimen</sample_type>
	<name>'+stone.name.encode(:xml => :text) +'</name>
	<igsn>'+igsn+'</igsn>
	<parent_igsn>'+parentigsn+'</parent_igsn>
	<is_private>0</is_private>
	<latitude>'+niltostring(stone.try(:place).try(:latitude)).to_s+'</latitude>
	<longitude>'+niltostring(stone.try(:place).try(:longitude)).to_s+'</longitude>
	<coordinate_system>WGS84</coordinate_system>
	<elevation>'+niltostring(stone.try(:place).try(:elevation)).to_s+'</elevation>
	<elevation_unit>m</elevation_unit>
	<primary_location_type>'+niltostring(stone.try(:place).try(:landuse)).try(:name).to_s+'</primary_location_type>
	<primary_location_name>'+niltostring(stone.try(:place).try(:name)).to_s+'</primary_location_name>
	<location_description>'+niltostring(stone.try(:place).try(:description)).to_s+'</location_description>
	<locality/>
	<locality_description/>
	<country>'+niltostring(country).to_s+'</country>
	<province>'+niltostring(province).to_s+'</province>
	<county/>
	<city></city>
	<material>'+niltostring(material).to_s+'</material>
	<classification>'+niltostring(classification).to_s+'</classification>
	<field_name>'+type+'</field_name>
	<depth_min>'+niltostring(stone.try(:sampledepth)).to_s+'</depth_min>
	<depth_max>'+niltostring(stone.try(:sampledepth)).to_s+'</depth_max>
	<depth_scale>m</depth_scale>
	<descriptions>
	<description>'+niltostring(stone.description).encode(:xml => :text)+'</description>
	</descriptions>
	<collection_method>'+niltostring(stone.try(:collectionmethod).try(:name)).encode(:xml => :text) +'</collection_method>
	<cruise_field_prgrm>'+niltostring(stone.try(:collection).try(:name)).encode(:xml => :text) +'</cruise_field_prgrm>
	<collector>'+niltostring(stone.try(:collectors).map(&:name).join(', ')).encode(:xml => :text) +'</collector>
        <collector_detail>'+niltostring(stone.try(:collectors).map(&:affiliation).join(', ')).encode(:xml => :text) +'</collector_detail>
	<collection_start_date>'+niltostring(stone.try(:date)).to_s+'</collection_start_date>
	<collection_end_date>'+niltostring(stone.try(:date)).to_s+'</collection_end_date>
	<collection_date_precision>day</collection_date_precision>
	<current_archive>'+niltostring(building).to_s.encode(:xml => :text) +'</current_archive>
	<current_archive_contact></current_archive_contact>
	<original_archive/>
	<original_archive_contact/>
	<launch_platform_name/>
	<relatedIdentifiers>
	'+niltostring(bibstring).to_s+'
	</relatedIdentifiers>
	</sample>
</record>
</supplementalMetadata>
</resource>'

end

def niltostring(str)
 	retstr= str.blank? ? '' : str 
 	return retstr.to_s.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
end

end
