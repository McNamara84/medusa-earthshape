class SearchMapsController < ApplicationController
  before_action :set_search_map, only: [:show]
#  load_and_authorize_resource
  # GET /search_maps
  # GET /search_maps.json
  def index
    @search = Stone.readables(current_user).search(params[:q].to_h)
    @stones=@search.result.page(params[:page]).per(params[:per_page])
    placeids=@search.result.map(&:place_id).uniq
    @places=Place.where(id: placeids).where.not('latitude' => nil).where.not('longitude' => nil)
    @hash = Gmaps4rails.build_markers(@places) do |place, marker|
       marker.lat place.latitude
       marker.lng place.longitude
       marker.json({:id => place.id })
       marker.infowindow Place.model_name.human+": "+place.name
    end
  end

  # GET /search_maps/1
  # GET /search_maps/1.json
 # def show
  #end

  # GET /search_maps/new
  #def new
  #end

  # GET /search_maps/1/edit
  #def edit
  #end

  # POST /search_maps
  # POST /search_maps.json
  #def create

#  end

  # PATCH/PUT /search_maps/1
  # PATCH/PUT /search_maps/1.json
  #def update

  #end

  # DELETE /search_maps/1
  # DELETE /search_maps/1.json
  #def destroy

 # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search_map
      @search_map = SearchMap.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_map_params
      params[:search_map]
    end
end
