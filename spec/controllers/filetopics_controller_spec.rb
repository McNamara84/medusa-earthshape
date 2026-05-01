require 'spec_helper'

describe FiletopicsController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:filetopic_1) { FactoryBot.create(:filetopic, name: "alpha") }
    let(:filetopic_2) { FactoryBot.create(:filetopic, name: "filetopic_2") }
    let(:filetopic_3) { FactoryBot.create(:filetopic, name: "filetopic_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      filetopic_1
      filetopic_2
      filetopic_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "id_in" => [filetopic_2.id, filetopic_3.id], "name_cont" => "filetopic", "s" => "updated_at DESC" } }

      it { expect(assigns(:filetopics)).to eq [filetopic_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "id_in" => [filetopic_2.id, filetopic_3.id], "name_cont" => "filetopic" } }

      it { expect(assigns(:filetopics)).to eq [filetopic_3] }
    end
  end

  describe "GET show" do
    let(:filetopic) { FactoryBot.create(:filetopic, name: "filetopic") }

    before { get :show, params: { id: filetopic.id }, format: :json }

    it { expect(response.body).to eq(filetopic.to_json) }
  end

  describe "GET edit" do
    let(:filetopic) { FactoryBot.create(:filetopic) }

    before { get :edit, params: { id: filetopic.id } }

    it { expect(assigns(:filetopic)).to eq filetopic }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "filetopic_name" } }

      it { expect { post :create, params: { filetopic: attributes } }.to change(Filetopic, :count).by(1) }

      it "assigns a persisted filetopic" do
        post :create, params: { filetopic: attributes }

        expect(assigns(:filetopic)).to be_persisted
        expect(assigns(:filetopic).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(Filetopic).to receive(:save).and_return(false) }

      it { expect { post :create, params: { filetopic: attributes } }.not_to change(Filetopic, :count) }

      it "assigns an unsaved filetopic" do
        post :create, params: { filetopic: attributes }

        expect(assigns(:filetopic)).to be_new_record
        expect(assigns(:filetopic).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:filetopic) { FactoryBot.create(:filetopic, name: "filetopic") }
    let(:attributes) { { name: "updated_filetopic" } }

    before { put :update, params: { id: filetopic.id, filetopic: attributes } }

    it { expect(assigns(:filetopic)).to eq filetopic }
    it { expect(assigns(:filetopic).name).to eq attributes[:name] }
    it { expect(response).to redirect_to(filetopics_path) }
  end

  describe "DELETE destroy" do
    let!(:filetopic) { FactoryBot.create(:filetopic, name: "filetopic") }

    it { expect { delete :destroy, params: { id: filetopic.id } }.to change(Filetopic, :count).by(-1) }
  end
end