class QuantityunitsController < ApplicationController
  respond_to :html, :xml, :json	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = Quantityunit.search(params[:q]&.permit! || {})
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @quantityunits = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @quantityunits
  end

  def show
    respond_with @quantityunit	  
  end

  def edit
    respond_with @quantityunit
  end

  def create
    @quantityunit = Quantityunit.new(quantityunit_params)
    @quantityunit.save
    respond_with @quantityunit	  	  
  end

  def update
    @quantityunit.update_attributes(quantityunit_params)
    redirect_to quantityunit_path	  
  end

  def destroy
    @quantityunit.destroy
    respond_with @quantityunit
  end

  private

  def quantityunit_params
    params.require(:quantityunit).permit(
      :name
    )
  end

  def find_resource
    @quantityunit= Quantityunit.find(params[:id])
  end    
end
