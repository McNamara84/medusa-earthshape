class PreparationTypesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = PreparationType.search(params[:q]&.permit! || {})
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @preparation_types = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @preparation_type
  end

  def show
    respond_with @preparation_type
  end

  def edit
    respond_with @preparation_type
  end

  def create
    @preparation_type = PreparationType.new(preparation_type_params)
    @preparation_type.save
    respond_with @preparation_type
  end

  def update
    @preparation_type.update(preparation_type_params)
    redirect_to  preparation_types_path
  end

  def destroy
    @preparation_type.destroy
    respond_with @preparation_type
  end

  private

  def preparation_type_params
    params.require(:preparation_type).permit(
      :name,
      :full_name,
      :description,
      :parent_id
    )
  end

  def find_resource
    @preparation_type= PreparationType.find(params[:id])
  end

end
