class NestedResources::PreparationsController < ApplicationController

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @preparations = @parent.preparations
    respond_with @preparations
  end

  def create
    @preparation = Preparation.new(preparation_params)
    @parent.preparations << @preparation
    respond_with @preparation, location: adjust_url_by_requesting_tab(safe_referer_url), action: "error"
  end

  def update
    @preparation= Preparation.find(params[:id])
    @parent.preparations << @preparation
    respond_with @preparation, location: adjust_url_by_requesting_tab(safe_referer_url)
  end

  def destroy
    @preparation= Preparation.find(params[:id])
    @parent.preparations.delete(@preparation)
    respond_with @preparation, location: adjust_url_by_requesting_tab(safe_referer_url)
  end

  def link_by_global_id
    @preparation= Preparation.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false)
    @parent.preparations << @preparation
    respond_with @preparation, location: adjust_url_by_requesting_tab(safe_referer_url)
  rescue
    duplicate_global_id
  end

  private

  def preparation_params
    params.require(:preparation).permit(
      :info,
      :stone_id,
      :preparation_type_id,
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
        :guest_writable,
        :published,
        :published_at
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
