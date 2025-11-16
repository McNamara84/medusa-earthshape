class NestedResources::StonesController < ApplicationController

  respond_to  :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @stones = @parent.send(params[:association_name])
    respond_with @stones
  end

  def create
    @stone = Stone.new(stone_params)
#    logger.info stone_params.inspect    
#    logger.info @stone.inspect    
    @parent.send(params[:association_name]) << @stone if @stone.save
    @stone.copy_associations(@parent)    
    respond_with @stone, location: adjust_url_by_requesting_tab(request.referer), action: "error" 
  end

  def update
    @stone = Stone.find(params[:id])
    @parent.send(params[:association_name]) << @stone
    respond_with @stone
  end

  def destroy
    @stone = Stone.find(params[:id])
    @parent.send(params[:association_name]).delete(@stone)
    respond_with @stone, location: adjust_url_by_requesting_tab(request.referer)
  end

  def link_by_global_id
    @stone = Stone.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false)
    @parent.send(params[:association_name]) << @stone
    respond_with @stone, location: adjust_url_by_requesting_tab(request.referer)
  rescue
    duplicate_global_id
  end

  private

  def stone_params
    params.require(:stone).permit(
      :name,
      :physical_form_id,
      :classification_id,
      :quantity,
      :quantity_unit,
      :quantityunit_id,      
      :tag_list,
      :parent_id,
      :box_id,
      :place_id,
      :description,
      :place_global_id,
      :box_global_id,
      :collection_global_id,
      :collection_id,   
      :collectionmethod_id,             
      :quantity_initial,
      :igsn,
      :stonecontainer_type_id,
      :labname,
      :tag_list,
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
        :guest_writable,
        :published,
        :published_at
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
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

  def duplicate_global_id
    respond_to do |format|
      format.html { render "parts/duplicate_global_id", status: :unprocessable_entity }
      format.all { head :unprocessable_entity }
    end
  end

end
