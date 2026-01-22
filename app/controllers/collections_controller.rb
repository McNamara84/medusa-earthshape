class CollectionsController < ApplicationController
  respond_to :html, :xml, :json, :modal
  before_action :find_resource, except: [:index, :new, :create, :bundle_edit, :bundle_update, :download_bundle_card, :download_label, :download_bundle_label, :import]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource
#  layout "admin_lab"

  def index
    @search = Collection.ransack(params[:q]&.permit! || {})
    @search.sorts = ["updated_at ASC"] if @search.sorts.empty?
    @collections = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @collections
  end

  def show
    respond_with @collection	  
  end

  def edit
    respond_with @collection, layout: !request.xhr?
  end
  
  def property
    respond_with @collection, layout: !request.xhr?
  end
  
  def map
     
     stones=Stone.where(collection_id: @collection.id).distinct(:place_id).map(&:place_id)
    @places=Place.where("id IN (?)",stones)
    @hash = Gmaps4rails.build_markers(@places) do |place, marker|
       marker.lat place.latitude
       marker.lng place.longitude
       marker.json({:id => place.id })
       marker.infowindow Place.model_name.human+": "+place.name
    end	  
    
    respond_with @stone, layout: !request.xhr?
  end
  
  def create
    @collection = Collection.new(collection_params)
    @collection.save
    respond_with @collection		  	  
  end

  def update
    @collection.update(collection_params)
    redirect_to @collection	  
  end

  def destroy
    @collection.destroy
    respond_with @collection
  end
  
  def bundle_update
    @collections.each { |collection| collection.update(collection_params.only_presence) }
    render :bundle_edit
  end  

  private

  def collection_params
      params.require(:collection).permit(
	:name, 
	:collector, 
	:affiliation, 
	:project, 
	:timeseries, 
	:collection_start, 
	:collection_end, 
	:depth_min, 
	:depth_max, 
	:depth_unit, 
	:depth_comment, 
	:comment, 
	:collectionmethod_id, 
	:samplingstrategy,
	:weather_conditions,
      :user_id,
      :group_id,	
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
      ])
  end

  def find_resource
    @collection = Collection.find(params[:id])
  end

  def find_resources
    @collections = Collection.where(id: params[:ids])
  end
end
