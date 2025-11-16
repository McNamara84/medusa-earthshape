class LandusesController < ApplicationController
  respond_to :html, :xml, :json	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin_lab"

  def index
    @search = Landuse.search(params[:q].to_h)
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @landuses = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @landuses
  end

  def show
    respond_with @landuse  
  end

  def edit
    respond_with @landuse
  end

  def create
    @landuse = Landuse.new(landuse_params)
    @landuse.save
    respond_with @landuse	  	  
  end

  def update
    @landuse.update_attributes(landuse_params)
    redirect_to landuses_path	  
  end

  def destroy
    @landuse.destroy
    respond_with @landuse
  end

  private

  def landuse_params
    params.require(:landuse).permit(
      :name
    )
  end

  def find_resource
    @landuse= Landuse.find(params[:id])
  end

end
