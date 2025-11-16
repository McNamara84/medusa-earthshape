class PreparationForClassificationsController < ApplicationController
  respond_to :html, :xml, :json
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = PreparationForClassification.search(params[:q].to_h)
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @preparation_for_classifications = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @preparation_for_classification   
  end

  def show
    respond_with @preparation_for_classification	  
  end

  def edit
    respond_with @preparation_for_classification
  end

  def create
    @preparation_for_classification = PreparationForClassification.new(preparation_for_classification_params)
    @preparation_for_classification.save
    respond_with @preparation_for_classification	  	  
  end

  def update
    @preparation_for_classification.update_attributes(preparation_for_classification_params)
    redirect_to preparation_for_classifications_path	  
  end

  def destroy
    @preparation_for_classification.destroy
    respond_with @preparation_for_classification
  end

  private

  def preparation_for_classification_params
    params.require(:preparation_for_classification).permit(
      :preparation_type_id,
      :classification_id
    )
  end

  def find_resource
    @preparation_for_classification= PreparationForClassification.find(params[:id])
  end

end
