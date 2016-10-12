class PreparationsController < ApplicationController
  respond_to :html, :xml, :json	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = Preparation.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @preparations = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @preparations
  end

  def show
    respond_with @preparation	  
  end

  def edit
    respond_with @preparation
  end

  def create
    @preparation = Preparation.new(preparation_params)
    @preparation.save
    respond_with @preparation	  	  
  end

  def update
    @preparation.update_attributes(preparation_params)
    redirect_to preparations_path	  
  end

  def destroy
    @preparation.destroy
    respond_with @preparation
  end

  private

  def preparation_params
    params.require(:preparation).permit(
      :preparation_type_id,
      :stone_id,
      :info
    )
  end

  def find_resource
    @preparation= Preparation.find(params[:id])
  end

end
