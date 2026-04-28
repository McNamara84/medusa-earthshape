require 'spec_helper'

describe PreparationTypesController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:preparation_type_1) { FactoryBot.create(:preparation_type, name: "alpha") }
    let(:preparation_type_2) { FactoryBot.create(:preparation_type, name: "preparation_type_2") }
    let(:preparation_type_3) { FactoryBot.create(:preparation_type, name: "preparation_type_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      preparation_type_1
      preparation_type_2
      preparation_type_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "name_cont" => "preparation_type", "s" => "updated_at DESC" } }

      it { expect(assigns(:preparation_types)).to eq [preparation_type_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "name_cont" => "preparation_type" } }

      it { expect(assigns(:preparation_types)).to eq [preparation_type_3] }
    end
  end

  describe "GET show" do
    let(:preparation_type) { FactoryBot.create(:preparation_type, name: "preparation_type") }

    before { get :show, params: { id: preparation_type.id }, format: :json }

    it { expect(response.body).to eq(preparation_type.to_json) }
  end

  describe "GET edit" do
    let(:preparation_type) { FactoryBot.create(:preparation_type) }

    before { get :edit, params: { id: preparation_type.id } }

    it { expect(assigns(:preparation_type)).to eq preparation_type }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "preparation_type_name" } }

      it { expect { post :create, params: { preparation_type: attributes } }.to change(PreparationType, :count).by(1) }

      it "assigns a persisted preparation_type" do
        post :create, params: { preparation_type: attributes }

        expect(assigns(:preparation_type)).to be_persisted
        expect(assigns(:preparation_type).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(PreparationType).to receive(:save).and_return(false) }

      it { expect { post :create, params: { preparation_type: attributes } }.not_to change(PreparationType, :count) }

      it "assigns an unsaved preparation_type" do
        post :create, params: { preparation_type: attributes }

        expect(assigns(:preparation_type)).to be_new_record
        expect(assigns(:preparation_type).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:preparation_type) { FactoryBot.create(:preparation_type, name: "preparation_type") }
    let(:attributes) { { name: "updated_preparation_type" } }

    before { put :update, params: { id: preparation_type.id, preparation_type: attributes } }

    it { expect(assigns(:preparation_type)).to eq preparation_type }
    it { expect(assigns(:preparation_type).name).to eq attributes[:name] }
    it { expect(response).to redirect_to(preparation_types_path) }
  end

  describe "DELETE destroy" do
    let!(:preparation_type) { FactoryBot.create(:preparation_type, name: "preparation_type") }

    it { expect { delete :destroy, params: { id: preparation_type.id } }.to change(PreparationType, :count).by(-1) }
  end
end