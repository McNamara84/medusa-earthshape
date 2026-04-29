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
end