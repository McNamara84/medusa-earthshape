class TopographicPositionsController < ApplicationController
  respond_to :html, :xml, :json, :modal	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin_lab"

  def index
    @search = TopographicPosition.ransack(params[:q]&.permit! || {})
    @search.sorts = ["updated_at ASC"] if @search.sorts.empty?
    @topographic_positions = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @topographic_positions
  end

  def show
    respond_with @topographic_position
  end

  def edit
    respond_with @topographic_position
  end

  def create
    @topographic_position= TopographicPosition.new(topographic_position_params)
    @topographic_position.save
    respond_with @topographic_position	  	  
  end

  def update
    @topographic_position.update(topographic_position_params)
    redirect_to topographic_positions_path	  
  end

  def destroy
    @topographic_position.destroy
    respond_with @topographic_position
  end

  private

  def topographic_position_params
    params.require(:topographic_position).permit(
      :name
    )
  end

  def find_resource
    @topographic_position= TopographicPosition.find(params[:id])
  end

end
