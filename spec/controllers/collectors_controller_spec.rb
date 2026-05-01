require 'spec_helper'

describe CollectorsController do
  render_views

  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let!(:collector_1) { Collector.create!(name: "collector_1", affiliation: "affiliation_1", stone: FactoryBot.create(:stone)) }
    let!(:collector_2) { Collector.create!(name: "collector_2", affiliation: "affiliation_2", stone: FactoryBot.create(:stone)) }

    before { get :index }

    it { expect(assigns(:collectors)).to contain_exactly(collector_1, collector_2) }
  end

  describe "GET show" do
    let(:collector) { Collector.create!(name: "collector", affiliation: "affiliation", stone: FactoryBot.create(:stone)) }

    before { get :show, params: { id: collector.id }, format: :json }

    it "renders the collector as json" do
      parsed_body = JSON.parse(response.body)

      expect(parsed_body["id"]).to eq(collector.id)
      expect(parsed_body["name"]).to eq(collector.name)
      expect(parsed_body["affiliation"]).to eq(collector.affiliation)
      expect(parsed_body["stone_id"]).to eq(collector.stone_id)
    end
  end

  describe "GET new" do
    before { get :new }

    it { expect(assigns(:collector)).to be_a_new(Collector) }
  end

  describe "GET edit" do
    let(:collector) { Collector.create!(name: "collector", affiliation: "affiliation", stone: FactoryBot.create(:stone)) }

    before { get :edit, params: { id: collector.id } }

    it { expect(assigns(:collector)).to eq collector }
  end

  describe "POST create" do
    describe "with valid html attributes" do
      let(:stone) { FactoryBot.create(:stone) }
      let(:attributes) { { name: "collector_name", affiliation: "new affiliation", stone_id: stone.id } }

      it { expect { post :create, params: { collector: attributes } }.to change(Collector, :count).by(1) }

      it "redirects to the created collector" do
        post :create, params: { collector: attributes }

        expect(assigns(:collector)).to be_persisted
        expect(response).to redirect_to(assigns(:collector))
      end
    end

    describe "with invalid html attributes" do
      let(:stone) { FactoryBot.create(:stone) }
      let(:attributes) { { name: "", affiliation: "new affiliation", stone_id: stone.id } }

      before { post :create, params: { collector: attributes } }

      it { expect(assigns(:collector)).to be_a_new(Collector) }
      it { expect(response).to render_template("new") }
    end

    describe "with valid json attributes" do
      let(:stone) { FactoryBot.create(:stone) }
      let(:attributes) { { name: "collector_name", affiliation: "json affiliation", stone_id: stone.id } }

      before { post :create, params: { collector: attributes }, format: :json }

      it { expect(response).to have_http_status(:created) }
      it { expect(JSON.parse(response.body)["name"]).to eq("collector_name") }
    end

    describe "with invalid json attributes" do
      let(:attributes) { { name: "", affiliation: "json affiliation", stone_id: nil } }

      before { post :create, params: { collector: attributes }, format: :json }

      it { expect(response).to have_http_status(:unprocessable_content) }
    end
  end

  describe "PUT update" do
    let(:collector) { Collector.create!(name: "collector", affiliation: "affiliation", stone: FactoryBot.create(:stone)) }

    describe "with valid html attributes" do
      let(:attributes) { { name: "updated_collector", affiliation: "updated affiliation" } }

      before { put :update, params: { id: collector.id, collector: attributes } }

      it { expect(assigns(:collector)).to eq collector }
      it { expect(assigns(:collector).name).to eq attributes[:name] }
      it { expect(assigns(:collector).affiliation).to eq attributes[:affiliation] }
      it { expect(response).to redirect_to(collector) }
    end

    describe "with invalid html attributes" do
      let(:attributes) { { name: "", affiliation: "updated affiliation" } }

      before { put :update, params: { id: collector.id, collector: attributes } }

      it { expect(assigns(:collector)).to eq collector }
      it { expect(response).to render_template("edit") }
    end

    describe "with valid json attributes" do
      let(:attributes) { { name: "updated_collector" } }

      before { put :update, params: { id: collector.id, collector: attributes }, format: :json }

      it { expect(response).to have_http_status(:no_content) }
    end

    describe "with invalid json attributes" do
      let(:attributes) { { name: "" } }

      before { put :update, params: { id: collector.id, collector: attributes }, format: :json }

      it { expect(response).to have_http_status(:unprocessable_content) }
    end
  end

  describe "DELETE destroy" do
    let!(:collector) { Collector.create!(name: "collector", affiliation: "affiliation", stone: FactoryBot.create(:stone)) }

    it "deletes the collector through html" do
      expect { delete :destroy, params: { id: collector.id } }.to change(Collector, :count).by(-1)
      expect(response).to redirect_to(collectors_url)
    end

    it "deletes the collector through json" do
      collector

      expect { delete :destroy, params: { id: collector.id }, format: :json }.to change(Collector, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end