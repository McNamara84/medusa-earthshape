class StagingsController < ApplicationController
  before_action :set_staging, only: [:show, :edit, :update, :destroy, :ingest]
  respond_to  :html, :xml, :json
  # GET /stagings
  # GET /stagings.json
  def index
    @stagings = []
    @boxes = Hash.new
    @stones = Hash.new
    @collections = Hash.new
    @places = Hash.new
    @preparations = Hash.new

    Staging.all.each do |s|
      if s.writable?(current_user)
        @stagings.push(s)
      end
    end

    @stagings.each do |staging|
      box = findbox(staging)
      place = findplace(staging)
      collection = findcollection(staging)
      stone = findstone(staging, getboxbyname(staging), getlocationbyname(staging), getcampaignbyname(staging))

      # preparations = findpreparation(staging)
      @boxes[staging.id] = box
      @places[staging.id] = place
      @collections[staging.id] = collection
      @stones[staging.id] = stone
      # @preparations[staging.id] = preparations
      # logger.info @places.inspect
    end
  end
  
  def findpreparation(staging)
      ret1 = PreparationType.where("name ILIKE ?", "#{staging.treatment_preparation1 }%").take.try!(:id).try(:to_i)
      ret2 = PreparationType.where("name ILIKE ?", "#{staging.treatment_preparation2 }%").take.try!(:id).try(:to_i)
      ret3 = PreparationType.where("name ILIKE ?", "#{staging.treatment_preparation3 }%").take.try!(:id).try(:to_i)
      [ret1, ret2, ret3]
  end
  
  def getboxbyname(staging)
    Box.where("name ILIKE ?", "#{staging.sample_storageroom }%").take.try!(:id).try(:to_i)
  end
  
  def getlocationbyname(staging)
    Place.where("is_parent IS NOT TRUE AND name ILIKE ?", "#{staging.sample_location }%").take.try!(:id).try(:to_i)
  end

  def getcampaignbyname(staging)
    Collection.where("name ILIKE ?", "#{staging.sample_campaign}%").take.try!(:id).try(:to_i)
  end  
  
  def findbox (staging)
    # search for box
    type = BoxType.where("name ILIKE ?", "#{staging.box_type }%").take.try!(:id).try(:to_i)
    groupid = Group.where("name = ?", "#{staging.box_group}").take.try!(:id).try(:to_i)

    parent = if staging.box_parent.present?
      Box.where("name ILIKE ?", "#{staging.box_parent }%").take.try!(:id).try(:to_i)
    end

    ret = {:name => staging.box_name, :parent_id => parent, :box_type => staging.box_type, :box_type_id => type, :box_group_id => groupid}
    logger.info ret
    ret
  end

  def findplace (staging)
    vegetation = Vegetation.where("name ILIKE ?", "#{staging.place_vegetation }%").take.try!(:id).try(:to_i)
    landuse = Landuse.where("name ILIKE ?", "#{staging.place_landuse }%").take.try!(:id).try(:to_i)
    topographic_position = TopographicPosition.where("name ILIKE ?", "#{staging.place_topographic_position }%").take.try!(:id).try(:to_i)
    parent_global_id = Place.where("is_parent IS TRUE AND places.name ILIKE ?", "#{staging.place_parent }%").joins(:record_property).take.try!(:global_id)
    groupid = Group.where("name = ?", "#{staging.place_group}").take.try!(:id).try(:to_i)

    ret = {
      :name => staging.place_name,
      :parent_global_id => parent_global_id,
      :longitude => staging.place_longitude,
      :latitude => staging.place_latitude,
      :elevation => staging.place_elevation,
      :topographic_position_id => topographic_position,
      :slope_description => staging.place_slopedescription,
      :aspect => staging.place_aspect,
      :vegetation_id => vegetation,
      :landuse_id => landuse,
      :description => staging.place_description,
      :lightsituation => staging.place_lightsituation,
      :place_group_id => groupid
    }

    ret
  end

  def findcollection (staging)
    groupid = Group.where("name = ?", "#{staging.collection_group}").take.try!(:id).try(:to_i)

    ret = {
      :name => staging.collection_name,
      :project => staging.collection_project,
      :timeseries => staging.collection_timeseries,
      :comment => staging.collection_comment,
      :samplingstrategy => staging.collection_strategy,
      :weather_conditions => staging.collection_weather,
      :collection_group_id => groupid
    }

    ret
  end

  def findstone (staging, box_id, place_id, collection_id)
    # determine classification_id
    material_id = Classification.where("parent_id IS NULL AND name ILIKE ?", "#{staging.sample_material }%").take.try!(:id).try(:to_i)
    classification_id = Classification.where("parent_id = ? AND name ILIKE ?", material_id, "#{staging.sample_classification }%").take.try!(:id).try(:to_i)
    if classification_id.blank? and staging.sample_classification.present?
      classificationarray = staging.sample_classification.split(" ")
      if classificationarray.length > 0
        classification_id = Classification.where("parent_id = ? AND name ILIKE ?", material_id, "#{ classificationarray[1]}%").take.try!(:id).try(:to_i)
      end
    end

    stonecontainer_type_id = StonecontainerType.where("name ILIKE ?", "#{staging.sample_container }%").take.try!(:id).try(:to_i)

    groupid = Group.where("name = ?", "#{staging.sample_group}").take.try!(:id).try(:to_i)

    collectionmethod = Collectionmethod.where("name ILIKE ?", "#{staging.sample_collectionmethod }%").take.try!(:id).try(:to_i)

    if staging.sample_parent.present?
      parent_id = Stone.where("stones.name ILIKE ?", "#{staging.sample_parent }%").take.try!(:id)
    else
      parent_id = nil
    end

    ret = {
      :name => staging.sample_name,
      :parent_id => parent_id,
      :igsn => staging.sample_igsn,
      :labname => staging.sample_labname,
      :date => staging.sample_date,
      :sampledepth => staging.sample_depth,
      :description => staging.sample_comment,
      :material_id => material_id,
      :classification_id => classification_id,
      :stonecontainer_type_id => stonecontainer_type_id,
      :quantity_initial => staging.sample_quantityinitial,
      :quantity_unit => staging.sample_unit,
      :quantity => staging.sample_quantity,
      :box_id => box_id,
      :place_id => place_id,
      :collection_id => collection_id,
      :collectionmethod_id => collectionmethod,
      :collector => staging.sample_collector,
      :affiliation => staging.sample_affiliation,
      :stone_group_id => groupid
    }

    ret
  end
  def clear
    Staging.all.each do |staging|
      staging.destroy if staging.user_id===@current_user.id
    end
    redirect_to stagings_path
  end

# GET /stagings/1
  # GET /stagings/1.json
  def show
    redirect_to stagings_path
  end

  # GET /stagings/new
  def new
    @staging = Staging.new
  end

  # GET /stagings/1/edit
  def edit
  end

  # POST /stagings
  # POST /stagings.json
  def create
    @staging = Staging.new(staging_params)

    respond_to do |format|
      if @staging.save
        format.html { redirect_to @staging, notice: 'Staging was successfully created.' }
        format.json { render action: 'show', status: :created, location: @staging }
      else
        format.html { render action: 'new' }
        format.json { render json: @staging.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stagings/1
  # PATCH/PUT /stagings/1.json
  def update
    respond_to do |format|
      if @staging.update(staging_params)
        format.html { redirect_to @staging, notice: 'Staging was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @staging.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stagings/1
  # DELETE /stagings/1.json
  def destroy
    @staging.destroy
    respond_to do |format|
      format.html { redirect_to stagings_url }
      format.json { head :no_content }
    end
  end

  def ingest_box
    ingest_record(:box_create_attributes, Box, "box_invalid")
  end

  def ingest_place
    ingest_record(:place_create_attributes, Place, "place_invalid")
  end

  def ingest_collection
    ingest_record(:collection_create_attributes, Collection, "collection_invalid")
  end

  def ingest_stone
    ingest_record(:stone_create_attributes, Stone, "stone_invalid")
  end

  def ingest
    # unused function
    redirect_to stagings_path
  end

  
  def import
    if Staging.import_csv(params[:data])
       redirect_to stagings_path
    else
      render "import_invalid", :locals => {:error => "error reading file"}
    end
    rescue ActiveRecord::RecordInvalid => invalid
      render "import_invalid", :locals => {:error => invalid.record.errors} 
    rescue StandardError => e
      logger.error("[StagingsController#import] CSV import failed: #{e.class}: #{e.message}")
      logger.error(e.full_message(highlight: false))
      render "import_invalid", :locals => {:error => e.message} 
    rescue Exception => e
      logger.error("[StagingsController#import] Unexpected exception during CSV import: #{e.class}: #{e.message}")
      logger.error(e.full_message(highlight: false))
      render "import_invalid", :locals => {:error => "error parsing file"}       
  end  

  private
    def ingest_record(attributes_key, model_class, invalid_template)
      attrs = staging_params.fetch(attributes_key)
      if attrs[:id].present?
        record = model_class.find(attrs[:id])
        record.update!(attrs)
      else
        record = model_class.new(attrs)
        record.save!
      end

      respond_with @stagings, location: adjust_url_by_requesting_tab(safe_referer_url)
    rescue StandardError => e
      logger.error(
        "[StagingsController#ingest_record] Failed (#{model_class}): #{e.class}: #{e.message} " \
        "attributes_key=#{attributes_key.inspect}"
      )
      logger.error(e.full_message(highlight: false))
      render invalid_template
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_staging
      @staging = Staging.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def staging_params
      params.require(:staging).permit(
      box_create_attributes: [
              :id, 
              :name,
              :parent_id,
              :box_type_id,
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
              ]
      ],
      place_create_attributes: [
              :id, 
              :name, 
              :latitude,
              :parent_global_id, 
              :longitude, 
              :elevation, 
              :topographic_position_id,
              :slope_description, 
              :aspect, 
              :vegetation_id, 
              :landuse_id, 
              :description,
              :lightsituation,
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
              ]
      ],
      collection_create_attributes: [
              :id,
              :name, 
              :project, 
              :timeseries,
              :comment,
              :samplingstrategy, 
              :weather_conditions,
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
              ]
      ],
      stone_create_attributes: [
              :id,
              :name,
              :parent_id,
              :igsn,
              :collectionmethod_id,
              :classification_id,
              :place_id,
              :collection_id,
              :sampledepth,
              :date,
              :quantity_initial,
              :quantity_unit,
              :quantity,
              :labname,
              :box_id,
              :stonecontainer_type_id,
              :description,
              collectors_attributes: [
                :name,
                :affiliation,
              ],
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
              ]
      ])
    end
end
