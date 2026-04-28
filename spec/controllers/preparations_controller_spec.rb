require 'spec_helper'

describe PreparationsController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:preparation_1) { FactoryBot.create(:preparation, info: "alpha") }
    let(:preparation_2) { FactoryBot.create(:preparation, info: "preparation_2") }
    let(:preparation_3) { FactoryBot.create(:preparation, info: "preparation_3") }

    before do
      preparation_1
      preparation_2
      preparation_3
      get :index, params: { q: { id_in: [preparation_1.id, preparation_2.id, preparation_3.id] }, page: 2, per_page: 1 }
    end

    it { expect(assigns(:preparations)).to eq [preparation_2] }
  end

  describe "GET show" do
    let(:preparation) { FactoryBot.create(:preparation, :with_associations) }

    before { get :show, params: { id: preparation.id }, format: :json }

    it { expect(response.body).to eq(preparation.to_json) }
  end

  describe "GET edit" do
    let(:preparation) { FactoryBot.create(:preparation, :with_associations) }

    before { get :edit, params: { id: preparation.id } }

    it { expect(assigns(:preparation)).to eq preparation }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) do
        {
          info: "New preparation info",
          preparation_type_id: FactoryBot.create(:preparation_type).id,
          stone_id: FactoryBot.create(:stone).id
        }
      end

      it { expect { post :create, params: { preparation: attributes } }.to change(Preparation, :count).by(1) }

      it "assigns a persisted preparation" do
        post :create, params: { preparation: attributes }

        expect(assigns(:preparation)).to be_persisted
        expect(assigns(:preparation).info).to eq(attributes[:info])
        expect(assigns(:preparation).preparation_type_id).to eq(attributes[:preparation_type_id])
        expect(assigns(:preparation).stone_id).to eq(attributes[:stone_id])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { info: "" } }

      before { allow_any_instance_of(Preparation).to receive(:save).and_return(false) }

      it { expect { post :create, params: { preparation: attributes } }.not_to change(Preparation, :count) }

      it "assigns an unsaved preparation" do
        post :create, params: { preparation: attributes }

        expect(assigns(:preparation)).to be_new_record
        expect(assigns(:preparation).info).to eq(attributes[:info])
      end
    end
  end

  describe "PUT update" do
    let(:preparation) { FactoryBot.create(:preparation, :with_associations, info: "Old preparation info") }
    let(:attributes) { { info: "Updated preparation info" } }

    before { put :update, params: { id: preparation.id, preparation: attributes } }

    it { expect(assigns(:preparation)).to eq preparation }
    it { expect(assigns(:preparation).info).to eq(attributes[:info]) }
    it { expect(response).to redirect_to(preparations_path) }
  end

  describe "DELETE destroy" do
    let!(:preparation) { FactoryBot.create(:preparation, :with_associations) }

    it { expect { delete :destroy, params: { id: preparation.id } }.to change(Preparation, :count).by(-1) }
  end
end