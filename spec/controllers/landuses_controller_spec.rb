require 'spec_helper'

describe LandusesController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:landuse_1) { FactoryBot.create(:landuse, name: "alpha") }
    let(:landuse_2) { FactoryBot.create(:landuse, name: "landuse_2") }
    let(:landuse_3) { FactoryBot.create(:landuse, name: "landuse_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      landuse_1
      landuse_2
      landuse_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "name_cont" => "landuse", "s" => "updated_at DESC" } }

      it { expect(assigns(:landuses)).to eq [landuse_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "name_cont" => "landuse" } }

      it { expect(assigns(:landuses)).to eq [landuse_3] }
    end
  end

  describe "GET show" do
    let(:landuse) { FactoryBot.create(:landuse, name: "landuse") }

    before { get :show, params: { id: landuse.id }, format: :json }

    it { expect(response.body).to eq(landuse.to_json) }
  end

  describe "GET edit" do
    let(:landuse) { FactoryBot.create(:landuse) }

    before { get :edit, params: { id: landuse.id } }

    it { expect(assigns(:landuse)).to eq landuse }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "landuse_name" } }

      it { expect { post :create, params: { landuse: attributes } }.to change(Landuse, :count).by(1) }

      it "assigns a persisted landuse" do
        post :create, params: { landuse: attributes }

        expect(assigns(:landuse)).to be_persisted
        expect(assigns(:landuse).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(Landuse).to receive(:save).and_return(false) }

      it { expect { post :create, params: { landuse: attributes } }.not_to change(Landuse, :count) }

      it "assigns an unsaved landuse" do
        post :create, params: { landuse: attributes }

        expect(assigns(:landuse)).to be_new_record
        expect(assigns(:landuse).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:landuse) { FactoryBot.create(:landuse, name: "landuse") }

    describe "with valid attributes" do
      let(:attributes) { { name: "updated_landuse" } }

      before { put :update, params: { id: landuse.id, landuse: attributes } }

      it { expect(assigns(:landuse)).to eq landuse }
      it { expect(assigns(:landuse).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(landuses_path) }
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before do
        allow_any_instance_of(Landuse).to receive(:update).and_return(false)
        put :update, params: { id: landuse.id, landuse: attributes }
      end

      it { expect(assigns(:landuse)).to eq landuse }
      it { expect(response).to redirect_to(landuses_path) }
    end
  end

  describe "DELETE destroy" do
    let!(:landuse) { FactoryBot.create(:landuse, name: "landuse") }

    it { expect { delete :destroy, params: { id: landuse.id } }.to change(Landuse, :count).by(-1) }
  end
end