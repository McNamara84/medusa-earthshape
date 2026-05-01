require 'spec_helper'

describe CollectionmethodsController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:collectionmethod_1) { Collectionmethod.create!(name: "hoge") }
    let(:collectionmethod_2) { Collectionmethod.create!(name: "collectionmethod_2") }
    let(:collectionmethod_3) { Collectionmethod.create!(name: "collectionmethod_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      collectionmethod_1
      collectionmethod_2
      collectionmethod_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "name_cont" => "collectionmethod", "s" => "updated_at DESC" } }

      it { expect(assigns(:collectionmethods)).to eq [collectionmethod_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "name_cont" => "collectionmethod" } }

      it { expect(assigns(:collectionmethods)).to eq [collectionmethod_3] }
    end
  end

  describe "GET show" do
    let(:collectionmethod) { Collectionmethod.create!(name: "collectionmethod") }

    before { get :show, params: { id: collectionmethod.id }, format: :json }

    it { expect(response.body).to eq(collectionmethod.to_json) }
  end

  describe "GET edit" do
    let(:collectionmethod) { Collectionmethod.create!(name: "collectionmethod") }

    before { get :edit, params: { id: collectionmethod.id } }

    it { expect(assigns(:collectionmethod)).to eq collectionmethod }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "collectionmethod_name" } }

      it { expect { post :create, params: { collectionmethod: attributes } }.to change(Collectionmethod, :count).by(1) }

      it "assigns a persisted collectionmethod" do
        post :create, params: { collectionmethod: attributes }

        expect(assigns(:collectionmethod)).to be_persisted
        expect(assigns(:collectionmethod).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(Collectionmethod).to receive(:save).and_return(false) }

      it { expect { post :create, params: { collectionmethod: attributes } }.not_to change(Collectionmethod, :count) }

      it "assigns an unsaved collectionmethod" do
        post :create, params: { collectionmethod: attributes }

        expect(assigns(:collectionmethod)).to be_new_record
        expect(assigns(:collectionmethod).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:collectionmethod) { Collectionmethod.create!(name: "collectionmethod") }
    let(:attributes) { { name: "updated_collectionmethod" } }

    before { put :update, params: { id: collectionmethod.id, collectionmethod: attributes } }

    it { expect(assigns(:collectionmethod)).to eq collectionmethod }
    it { expect(assigns(:collectionmethod).name).to eq attributes[:name] }
    it { expect(response).to redirect_to(collectionmethods_path) }
  end

  describe "DELETE destroy" do
    let!(:collectionmethod) { Collectionmethod.create!(name: "collectionmethod") }

    it { expect { delete :destroy, params: { id: collectionmethod.id } }.to change(Collectionmethod, :count).by(-1) }
  end
end