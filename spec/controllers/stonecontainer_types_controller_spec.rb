require 'spec_helper'

describe StonecontainerTypesController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:stonecontainer_type_1) { FactoryBot.create(:stonecontainer_type, name: "alpha") }
    let(:stonecontainer_type_2) { FactoryBot.create(:stonecontainer_type, name: "stonecontainer_type_2") }
    let(:stonecontainer_type_3) { FactoryBot.create(:stonecontainer_type, name: "stonecontainer_type_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      stonecontainer_type_1
      stonecontainer_type_2
      stonecontainer_type_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "id_in" => [stonecontainer_type_2.id, stonecontainer_type_3.id], "name_cont" => "stonecontainer_type", "s" => "updated_at DESC" } }

      it { expect(assigns(:stonecontainer_types)).to eq [stonecontainer_type_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "id_in" => [stonecontainer_type_2.id, stonecontainer_type_3.id], "name_cont" => "stonecontainer_type" } }

      it { expect(assigns(:stonecontainer_types)).to eq [stonecontainer_type_3] }
    end
  end

  describe "GET show" do
    let(:stonecontainer_type) { FactoryBot.create(:stonecontainer_type, name: "stonecontainer_type") }

    before { get :show, params: { id: stonecontainer_type.id }, format: :json }

    it { expect(response.body).to eq(stonecontainer_type.to_json) }
  end

  describe "GET edit" do
    let(:stonecontainer_type) { FactoryBot.create(:stonecontainer_type) }

    before { get :edit, params: { id: stonecontainer_type.id } }

    it { expect(assigns(:stonecontainer_type)).to eq stonecontainer_type }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "stonecontainer_type_name" } }

      it { expect { post :create, params: { stonecontainer_type: attributes } }.to change(StonecontainerType, :count).by(1) }

      it "assigns a persisted stonecontainer_type" do
        post :create, params: { stonecontainer_type: attributes }

        expect(assigns(:stonecontainer_type)).to be_persisted
        expect(assigns(:stonecontainer_type).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(StonecontainerType).to receive(:save).and_return(false) }

      it { expect { post :create, params: { stonecontainer_type: attributes } }.not_to change(StonecontainerType, :count) }

      it "assigns an unsaved stonecontainer_type" do
        post :create, params: { stonecontainer_type: attributes }

        expect(assigns(:stonecontainer_type)).to be_new_record
        expect(assigns(:stonecontainer_type).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:stonecontainer_type) { FactoryBot.create(:stonecontainer_type, name: "stonecontainer_type") }
    let(:attributes) { { name: "updated_stonecontainer_type" } }

    before { put :update, params: { id: stonecontainer_type.id, stonecontainer_type: attributes } }

    it { expect(assigns(:stonecontainer_type)).to eq stonecontainer_type }
    it { expect(assigns(:stonecontainer_type).name).to eq attributes[:name] }
    it { expect(response).to redirect_to(stonecontainer_types_path) }
  end

  describe "DELETE destroy" do
    let!(:stonecontainer_type) { FactoryBot.create(:stonecontainer_type, name: "stonecontainer_type") }

    it { expect { delete :destroy, params: { id: stonecontainer_type.id } }.to change(StonecontainerType, :count).by(-1) }
  end
end