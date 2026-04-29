require 'spec_helper'

describe TopographicPositionsController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:topographic_position_1) { FactoryBot.create(:topographic_position, name: "alpha") }
    let(:topographic_position_2) { FactoryBot.create(:topographic_position, name: "topographic_position_2") }
    let(:topographic_position_3) { FactoryBot.create(:topographic_position, name: "topographic_position_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      topographic_position_1
      topographic_position_2
      topographic_position_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "name_cont" => "topographic_position", "s" => "updated_at DESC" } }

      it { expect(assigns(:topographic_positions)).to eq [topographic_position_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "name_cont" => "topographic_position" } }

      it { expect(assigns(:topographic_positions)).to eq [topographic_position_3] }
    end
  end

  describe "GET show" do
    let(:topographic_position) { FactoryBot.create(:topographic_position, name: "topographic_position") }

    before { get :show, params: { id: topographic_position.id }, format: :json }

    it { expect(response.body).to eq(topographic_position.to_json) }
  end

  describe "GET edit" do
    let(:topographic_position) { FactoryBot.create(:topographic_position) }

    before { get :edit, params: { id: topographic_position.id } }

    it { expect(assigns(:topographic_position)).to eq topographic_position }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "topographic_position_name" } }

      it { expect { post :create, params: { topographic_position: attributes } }.to change(TopographicPosition, :count).by(1) }

      it "assigns a persisted topographic_position" do
        post :create, params: { topographic_position: attributes }

        expect(assigns(:topographic_position)).to be_persisted
        expect(assigns(:topographic_position).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(TopographicPosition).to receive(:save).and_return(false) }

      it { expect { post :create, params: { topographic_position: attributes } }.not_to change(TopographicPosition, :count) }

      it "assigns an unsaved topographic_position" do
        post :create, params: { topographic_position: attributes }

        expect(assigns(:topographic_position)).to be_new_record
        expect(assigns(:topographic_position).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:topographic_position) { FactoryBot.create(:topographic_position, name: "topographic_position") }

    describe "with valid attributes" do
      let(:attributes) { { name: "updated_topographic_position" } }

      before { put :update, params: { id: topographic_position.id, topographic_position: attributes } }

      it { expect(assigns(:topographic_position)).to eq topographic_position }
      it { expect(assigns(:topographic_position).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(topographic_positions_path) }
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before do
        allow_any_instance_of(TopographicPosition).to receive(:update).and_return(false)
        put :update, params: { id: topographic_position.id, topographic_position: attributes }
      end

      it { expect(assigns(:topographic_position)).to eq topographic_position }
      it { expect(response).to redirect_to(topographic_positions_path) }
    end
  end

  describe "DELETE destroy" do
    let!(:topographic_position) { FactoryBot.create(:topographic_position, name: "topographic_position") }

    it { expect { delete :destroy, params: { id: topographic_position.id } }.to change(TopographicPosition, :count).by(-1) }
  end
end