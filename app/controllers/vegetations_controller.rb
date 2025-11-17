class VegetationsController < ApplicationController
  respond_to :html, :xml, :json	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin_lab"

  def index
    @search = Vegetation.search(params[:q]&.permit! || {})
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @vegetations = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @vegetations
  end

  def show
    respond_with @vegetation  
  end

  def edit
    respond_with @vegetation
  end

  def create
    @vegetation = Vegetation.new(vegetation_params)
    @vegetation.save
    respond_with @vegetation	  	  
  end

  def update
    @vegetation.update(vegetation_params)
    redirect_to vegetations_path	  
  end

  def destroy
    @vegetation.destroy
    respond_with @vegetation
  end

  private

  def vegetation_params
    params.require(:vegetation).permit(
      :name
    )
  end

  def find_resource
    @vegetation= Vegetation.find(params[:id])
  end
end
