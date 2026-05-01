require 'spec_helper'

describe PreparationForClassificationsController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:preparation_for_classification_1) do
      PreparationForClassification.create!(preparation_type: FactoryBot.create(:preparation_type), classification: FactoryBot.create(:classification))
    end
    let(:preparation_for_classification_2) do
      PreparationForClassification.create!(preparation_type: FactoryBot.create(:preparation_type), classification: FactoryBot.create(:classification))
    end
    let(:preparation_for_classification_3) do
      PreparationForClassification.create!(preparation_type: FactoryBot.create(:preparation_type), classification: FactoryBot.create(:classification))
    end

    before do
      preparation_for_classification_1
      preparation_for_classification_2
      preparation_for_classification_3
      get :index, params: { q: { id_in: [preparation_for_classification_1.id, preparation_for_classification_2.id, preparation_for_classification_3.id] }, page: 2, per_page: 1 }
    end

    it { expect(assigns(:preparation_for_classifications)).to eq [preparation_for_classification_2] }
  end

  describe "GET show" do
    let(:preparation_for_classification) do
      PreparationForClassification.create!(preparation_type: FactoryBot.create(:preparation_type), classification: FactoryBot.create(:classification))
    end

    before { get :show, params: { id: preparation_for_classification.id }, format: :json }

    it { expect(response.body).to eq(preparation_for_classification.to_json) }
  end

  describe "GET edit" do
    let(:preparation_for_classification) do
      PreparationForClassification.create!(preparation_type: FactoryBot.create(:preparation_type), classification: FactoryBot.create(:classification))
    end

    before { get :edit, params: { id: preparation_for_classification.id } }

    it { expect(assigns(:preparation_for_classification)).to eq preparation_for_classification }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) do
        {
          preparation_type_id: FactoryBot.create(:preparation_type).id,
          classification_id: FactoryBot.create(:classification).id
        }
      end

      it do
        expect {
          post :create, params: { preparation_for_classification: attributes }
        }.to change(PreparationForClassification, :count).by(1)
      end

      it "assigns a persisted preparation_for_classification" do
        post :create, params: { preparation_for_classification: attributes }

        expect(assigns(:preparation_for_classification)).to be_persisted
        expect(assigns(:preparation_for_classification).preparation_type_id).to eq(attributes[:preparation_type_id])
        expect(assigns(:preparation_for_classification).classification_id).to eq(attributes[:classification_id])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { preparation_type_id: nil, classification_id: nil } }

      before { allow_any_instance_of(PreparationForClassification).to receive(:save).and_return(false) }

      it do
        expect {
          post :create, params: { preparation_for_classification: attributes }
        }.not_to change(PreparationForClassification, :count)
      end

      it "assigns an unsaved preparation_for_classification" do
        post :create, params: { preparation_for_classification: attributes }

        expect(assigns(:preparation_for_classification)).to be_new_record
        expect(assigns(:preparation_for_classification).preparation_type_id).to be_nil
        expect(assigns(:preparation_for_classification).classification_id).to be_nil
      end
    end
  end

  describe "PUT update" do
    let(:preparation_for_classification) do
      PreparationForClassification.create!(preparation_type: FactoryBot.create(:preparation_type), classification: original_classification)
    end
    let(:original_classification) { FactoryBot.create(:classification) }
    let(:updated_classification) { FactoryBot.create(:classification, name: "updated classification", full_name: "updated classification") }
    let(:attributes) { { classification_id: updated_classification.id } }

    before do
      put :update, params: { id: preparation_for_classification.id, preparation_for_classification: attributes }
    end

    it { expect(assigns(:preparation_for_classification)).to eq preparation_for_classification }
    it { expect(assigns(:preparation_for_classification).classification_id).to eq(updated_classification.id) }
    it { expect(response).to redirect_to(preparation_for_classifications_path) }
  end

  describe "DELETE destroy" do
    let!(:preparation_for_classification) do
      PreparationForClassification.create!(preparation_type: FactoryBot.create(:preparation_type), classification: FactoryBot.create(:classification))
    end

    it do
      expect {
        delete :destroy, params: { id: preparation_for_classification.id }
      }.to change(PreparationForClassification, :count).by(-1)
    end
  end
end