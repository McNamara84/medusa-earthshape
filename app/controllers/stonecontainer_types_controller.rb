class StonecontainerTypesController < ApplicationController
 respond_to :html, :xml, :json	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = StonecontainerType.ransack(params[:q]&.permit! || {})
    @search.sorts = ["updated_at ASC"] if @search.sorts.empty?
    @stonecontainer_types = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @stonecontainer_types
  end

  def show
    respond_with @stonecontainer_type	  
  end

  def edit
    respond_with @stonecontainer_type
  end

  def create
    @stonecontainer_type = StonecontainerType.new(stonecontainer_type_params)
    @stonecontainer_type.save
    respond_with @stonecontainer_type	  	  
  end

  def update
    @stonecontainer_type.update(stonecontainer_type_params)
    redirect_to stonecontainer_types_path	  
  end

  def destroy
    @stonecontainer_type.destroy
    respond_with @stonecontainer_type
  end

  private

  def stonecontainer_type_params
    params.require(:stonecontainer_type).permit(
      :name
    )
  end

  def find_resource
    @stonecontainer_type= StonecontainerType.find(params[:id])
  end    
    
end
