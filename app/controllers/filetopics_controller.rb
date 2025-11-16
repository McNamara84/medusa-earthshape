class FiletopicsController < ApplicationController
 respond_to :html, :xml, :json	
  before_action  :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = Filetopic.search(params[:q]&.permit! || {})
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @filetopics = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @filetopics
  end

  def show
    respond_with @filetopic	  
  end

  def edit
    respond_with @filetopic
  end

  def create
    @filetopic = Filetopic.new(filetopic_params)
    @filetopic.save
    respond_with @filetopic	  	  
  end

  def update
    @filetopic.update_attributes(filetopic_params)
    redirect_to filetopic_path	  
  end

  def destroy
    @filetopic.destroy
    respond_with @filetopic
  end

  private

  def filetopic_params
    params.require(:filetopic).permit(
      :name
    )
  end

  def find_resource
    @filetopic= Filetopic.find(params[:id])
  end    
    
end
