require 'spec_helper'

describe QuantityunitsController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET index" do
    let(:quantityunit_1) { Quantityunit.create!(name: "hoge") }
    let(:quantityunit_2) { Quantityunit.create!(name: "quantityunit_2") }
    let(:quantityunit_3) { Quantityunit.create!(name: "quantityunit_3") }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      quantityunit_1
      quantityunit_2
      quantityunit_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "name_cont" => "quantityunit", "s" => "updated_at DESC" } }

      it { expect(assigns(:quantityunits)).to eq [quantityunit_2] }
    end

    context "sort condition is nil" do
      let(:query) { { "name_cont" => "quantityunit" } }

      it { expect(assigns(:quantityunits)).to eq [quantityunit_3] }
    end
  end

  describe "GET show" do
    let(:quantityunit) { Quantityunit.create!(name: "quantityunit") }

    before { get :show, params: { id: quantityunit.id }, format: :json }

    it { expect(response.body).to eq(quantityunit.to_json) }
  end

  describe "GET edit" do
    let(:quantityunit) { Quantityunit.create!(name: "quantityunit") }

    before { get :edit, params: { id: quantityunit.id } }

    it { expect(assigns(:quantityunit)).to eq quantityunit }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { { name: "quantityunit_name" } }

      it { expect { post :create, params: { quantityunit: attributes } }.to change(Quantityunit, :count).by(1) }

      it "assigns a persisted quantityunit" do
        post :create, params: { quantityunit: attributes }

        expect(assigns(:quantityunit)).to be_persisted
        expect(assigns(:quantityunit).name).to eq(attributes[:name])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "" } }

      before { allow_any_instance_of(Quantityunit).to receive(:save).and_return(false) }

      it { expect { post :create, params: { quantityunit: attributes } }.not_to change(Quantityunit, :count) }

      it "assigns an unsaved quantityunit" do
        post :create, params: { quantityunit: attributes }

        expect(assigns(:quantityunit)).to be_new_record
        expect(assigns(:quantityunit).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:quantityunit) { Quantityunit.create!(name: "quantityunit") }
    let(:attributes) { { name: "updated_quantityunit" } }

    before { put :update, params: { id: quantityunit.id, quantityunit: attributes } }

    it { expect(assigns(:quantityunit)).to eq quantityunit }
    it { expect(assigns(:quantityunit).name).to eq attributes[:name] }
    it { expect(response).to redirect_to(quantityunits_path) }
  end

  describe "DELETE destroy" do
    let!(:quantityunit) { Quantityunit.create!(name: "quantityunit") }

    it { expect { delete :destroy, params: { id: quantityunit.id } }.to change(Quantityunit, :count).by(-1) }
  end
end