require 'spec_helper'

describe CollectionsController do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
    User.current = user
  end

  after do
    User.current = nil
  end

  describe "GET index" do
    let(:collection_1) { FactoryBot.create(:collection, name: "alpha") }
    let(:collection_2) { FactoryBot.create(:collection, name: "collection_2") }
    let(:collection_3) { FactoryBot.create(:collection, name: "collection_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      collection_1
      collection_2
      collection_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "id_in" => [collection_2.id, collection_3.id], "name_cont" => "collection", "s" => "updated_at DESC" } }

      it { expect(assigns(:collections)).to eq [collection_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "id_in" => [collection_2.id, collection_3.id], "name_cont" => "collection" } }

      it { expect(assigns(:collections)).to eq [collection_3] }
    end
  end

  describe "GET show" do
    let(:collection) { FactoryBot.create(:collection, name: "collection") }

    before { get :show, params: { id: collection.id }, format: :json }

    it "renders the collection as json" do
      body = JSON.parse(response.body)

      expect(body["id"]).to eq(collection.id)
      expect(body["name"]).to eq(collection.name)
      expect(body["project"]).to eq(collection.project)
      expect(body["samplingstrategy"]).to eq(collection.samplingstrategy)
    end
  end

  describe "GET edit" do
    let(:collection) { FactoryBot.create(:collection) }

    before { get :edit, params: { id: collection.id } }

    it { expect(assigns(:collection)).to eq collection }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "collection_name", project: "project_name", samplingstrategy: "grid" } }

      it { expect { post :create, params: { collection: attributes } }.to change(Collection, :count).by(1) }

      it "assigns a persisted collection" do
        post :create, params: { collection: attributes }

        expect(assigns(:collection)).to be_persisted
        expect(assigns(:collection).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "", project: "", samplingstrategy: "" } }

      before { allow_any_instance_of(Collection).to receive(:save).and_return(false) }

      it { expect { post :create, params: { collection: attributes } }.not_to change(Collection, :count) }

      it "assigns an unsaved collection" do
        post :create, params: { collection: attributes }

        expect(assigns(:collection)).to be_new_record
        expect(assigns(:collection).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:collection) { FactoryBot.create(:collection, name: "collection") }
    let(:attributes) { { name: "updated_collection", project: collection.project, samplingstrategy: collection.samplingstrategy } }

    before { put :update, params: { id: collection.id, collection: attributes } }

    it { expect(assigns(:collection)).to eq collection }
    it { expect(assigns(:collection).name).to eq attributes[:name] }
    it { expect(response).to redirect_to(collection_path(collection)) }
  end

  describe "DELETE destroy" do
    let!(:collection) { FactoryBot.create(:collection, name: "collection") }

    it { expect { delete :destroy, params: { id: collection.id } }.to change(Collection, :count).by(-1) }
  end
end