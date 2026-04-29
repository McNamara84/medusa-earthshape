require 'spec_helper'

describe VegetationsController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:vegetation_1) { FactoryBot.create(:vegetation, name: "alpha") }
    let(:vegetation_2) { FactoryBot.create(:vegetation, name: "vegetation_2") }
    let(:vegetation_3) { FactoryBot.create(:vegetation, name: "vegetation_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      vegetation_1
      vegetation_2
      vegetation_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "id_in" => [vegetation_2.id, vegetation_3.id], "name_cont" => "vegetation", "s" => "updated_at DESC" } }

      it { expect(assigns(:vegetations)).to eq [vegetation_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "id_in" => [vegetation_2.id, vegetation_3.id], "name_cont" => "vegetation" } }

      it { expect(assigns(:vegetations)).to eq [vegetation_3] }
    end
  end

  describe "GET show" do
    let(:vegetation) { FactoryBot.create(:vegetation, name: "vegetation") }

    before { get :show, params: { id: vegetation.id }, format: :json }

    it { expect(response.body).to eq(vegetation.to_json) }
  end

  describe "GET edit" do
    let(:vegetation) { FactoryBot.create(:vegetation) }

    before { get :edit, params: { id: vegetation.id } }

    it { expect(assigns(:vegetation)).to eq vegetation }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "vegetation_name" } }

      it { expect { post :create, params: { vegetation: attributes } }.to change(Vegetation, :count).by(1) }

      it "assigns a persisted vegetation" do
        post :create, params: { vegetation: attributes }

        expect(assigns(:vegetation)).to be_persisted
        expect(assigns(:vegetation).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(Vegetation).to receive(:save).and_return(false) }

      it { expect { post :create, params: { vegetation: attributes } }.not_to change(Vegetation, :count) }

      it "assigns an unsaved vegetation" do
        post :create, params: { vegetation: attributes }

        expect(assigns(:vegetation)).to be_new_record
        expect(assigns(:vegetation).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:vegetation) { FactoryBot.create(:vegetation, name: "vegetation") }

    describe "with valid attributes" do
      let(:attributes) { { name: "updated_vegetation" } }

      before { put :update, params: { id: vegetation.id, vegetation: attributes } }

      it { expect(assigns(:vegetation)).to eq vegetation }
      it { expect(assigns(:vegetation).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(vegetations_path) }
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before do
        allow_any_instance_of(Vegetation).to receive(:update).and_return(false)
        put :update, params: { id: vegetation.id, vegetation: attributes }
      end

      it { expect(assigns(:vegetation)).to eq vegetation }
      it { expect(response).to redirect_to(vegetations_path) }
    end
  end

  describe "DELETE destroy" do
    let!(:vegetation) { FactoryBot.create(:vegetation, name: "vegetation") }

    it { expect { delete :destroy, params: { id: vegetation.id } }.to change(Vegetation, :count).by(-1) }
  end
end