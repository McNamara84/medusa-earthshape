class RecordPropertiesController < ApplicationController
  respond_to :html, :json, :xml
  before_action :find_resource
  before_action :authorize_parent_resource

  def show
    respond_with @record_property
  end

  def update
    @record_property.update(record_property_params)
    respond_with @record_property, location: safe_referer_url
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent_resource = resource_class.find(params["#{resource_name}_id"])
    @record_property = @parent_resource.record_property
  end

  def authorize_parent_resource
    action = action_name == "show" ? :read : :manage
    authorize!(action, @parent_resource)
  end

  def record_property_params
    params.require(:record_property).permit(
      :user_id,
      :group_id,
      :global_id,
      :published,
      :owner_writable,
      :group_readable,
      :group_writable,
      :guest_readable,
      :guest_writable
    )
  end

end
