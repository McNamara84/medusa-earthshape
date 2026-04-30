require 'spec_helper'

describe SearchMapsController do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user_foo) }

  before do
    sign_in user
    User.current = user
  end

  after do
    User.current = nil
  end

  describe "GET index" do
    let(:mapped_place) { FactoryBot.create(:place, name: "Mapped Place", latitude: 35.0, longitude: 135.0) }
    let(:place_without_coordinates) { FactoryBot.create(:place, name: "Unmapped Place", latitude: nil, longitude: nil) }
    let(:hidden_place) { FactoryBot.create(:place, name: "Hidden Place", latitude: 36.0, longitude: 136.0) }
    let(:visible_stone) { FactoryBot.create(:stone, name: "match_visible", place: mapped_place) }
    let(:visible_stone_without_coordinates) { FactoryBot.create(:stone, name: "match_unmapped", place: place_without_coordinates) }
    let(:hidden_stone) { FactoryBot.create(:stone, name: "match_hidden", place: hidden_place) }
    let(:markers) { [{ id: mapped_place.id }] }

    before do
      visible_stone
      visible_stone_without_coordinates

      User.current = other_user
      hidden_stone
      User.current = user

      allow(Gmaps4rails).to receive(:build_markers).and_return(markers)

      get :index, params: { q: { name_cont: "match" }, page: 1, per_page: 10 }
    end

    it "assigns only readable matching stones" do
      expect(assigns(:stones)).to match_array([visible_stone, visible_stone_without_coordinates])
    end

    it "filters places to records with coordinates" do
      expect(assigns(:places)).to eq([mapped_place])
    end

    it "builds map markers for the filtered places" do
      expect(Gmaps4rails).to have_received(:build_markers).with([mapped_place])
      expect(assigns(:hash)).to eq(markers)
    end
  end

  describe "GET index marker building" do
    let(:mapped_place) { FactoryBot.create(:place, name: "Mapped Place", latitude: 35.0, longitude: 135.0) }
    let(:visible_stone) { FactoryBot.create(:stone, name: "match_visible", place: mapped_place) }
    let(:marker) { instance_double("GmapsMarker") }
    let(:markers) { [{ id: mapped_place.id }] }

    before do
      visible_stone
      allow(marker).to receive(:lat)
      allow(marker).to receive(:lng)
      allow(marker).to receive(:json)
      allow(marker).to receive(:infowindow)
      allow(Gmaps4rails).to receive(:build_markers).with([mapped_place]) do |places, &block|
        places.each { |place| block.call(place, marker) }
        markers
      end

      get :index, params: { q: { name_cont: "match" }, page: 1, per_page: 10 }
    end

    it "fills the marker with place coordinates and metadata" do
      expect(marker).to have_received(:lat).with(mapped_place.latitude)
      expect(marker).to have_received(:lng).with(mapped_place.longitude)
      expect(marker).to have_received(:json).with(id: mapped_place.id)
      expect(marker).to have_received(:infowindow).with("#{Place.model_name.human}: Mapped Place")
    end
  end

  describe "private helpers" do
    describe "#set_search_map" do
      let!(:search_map) { SearchMap.create! }

      it "loads the requested search map" do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: search_map.id))

        controller.send(:set_search_map)

        expect(controller.instance_variable_get(:@search_map)).to eq(search_map)
      end
    end

    describe "#search_map_params" do
      it "returns the nested search_map params" do
        params = ActionController::Parameters.new(search_map: { zoom: "5", center: "52,13" })
        allow(controller).to receive(:params).and_return(params)

        expect(controller.send(:search_map_params)).to eq(params[:search_map])
      end
    end
  end
end