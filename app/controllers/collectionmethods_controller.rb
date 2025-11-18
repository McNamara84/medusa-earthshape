class CollectionmethodsController < ApplicationController   
  respond_to :html, :xml, :json	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = Collectionmethod.ransack(params[:q]&.permit! || {})
    @search.sorts = ["updated_at ASC"] if @search.sorts.empty?
    @collectionmethods = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @collectionmethods
  end

  def show
    respond_with @collectionmethod	  
  end

  def edit
    respond_with @collectionmethod
  end

  def create
    @collectionmethod = Collectionmethod.new(collectionmethod_params)
    @collectionmethod.save
    respond_with @collectionmethod	  	  
  end

  def update
    @collectionmethod.update(collectionmethod_params)
    redirect_to collectionmethods_path	  
  end

  def destroy
    @collectionmethod.destroy
    respond_with @collectionmethod
  end

  private

  def collectionmethod_params
    params.require(:collectionmethod).permit(
      :name
    )
  end

  def find_resource
    @collectionmethod= Collectionmethod.find(params[:id])
  end    
    
end
