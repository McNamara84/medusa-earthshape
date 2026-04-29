require 'spec_helper'

describe BibsController do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
    User.current = user
  end

  after do
    User.current = nil
  end

  describe "GET index" do
    let(:author_1) { FactoryBot.create(:author, name: "Author Alpha") }
    let(:author_2) { FactoryBot.create(:author, name: "Author Beta") }
    let(:author_3) { FactoryBot.create(:author, name: "Author Gamma") }
    let(:bib_1) { FactoryBot.create(:bib, name: "alpha", doi: "", authors: [author_1]) }
    let(:bib_2) { FactoryBot.create(:bib, name: "bib_2", doi: "", authors: [author_2]) }
    let(:bib_3) { FactoryBot.create(:bib, name: "bib_3", doi: "", authors: [author_3]) }
    let(:params) { { q: query, page: 2, per_page: 1 } }

    before do
      bib_1
      bib_2
      bib_3
      get :index, params: params
    end

    context "sort condition is present" do
      let(:query) { { "id_in" => [bib_2.id, bib_3.id], "name_cont" => "bib", "s" => "updated_at ASC" } }

      it { expect(assigns(:bibs)).to eq [bib_3] }
    end

    context "sort condition is nil" do
      let(:query) { { "id_in" => [bib_2.id, bib_3.id], "name_cont" => "bib" } }

      it { expect(assigns(:bibs)).to eq [bib_2] }
    end
  end

  describe "GET show" do
    let(:author) { FactoryBot.create(:author, name: "Show Author") }
    let(:bib) { FactoryBot.create(:bib, name: "bib", doi: "", authors: [author]) }

    before { get :show, params: { id: bib.id }, format: :json }

    it "renders the bib as json" do
      body = JSON.parse(response.body)

      expect(body["id"]).to eq(bib.id)
      expect(body["name"]).to eq(bib.name)
      expect(body["author_ids"]).to eq([author.id])
    end
  end

  describe "GET edit" do
    let(:author) { FactoryBot.create(:author, name: "Edit Author") }
    let(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }

    before { get :edit, params: { id: bib.id } }

    it { expect(assigns(:bib)).to eq bib }
  end

  describe "POST create" do
    let(:author) { FactoryBot.create(:author, name: "Create Author") }

    describe "with valid attributes" do
      let(:attributes) { { name: "bib_name", doi: "", entry_type: "misc", author_ids: [author.id] } }

      it { expect { post :create, params: { bib: attributes } }.to change(Bib, :count).by(1) }

      it "assigns a persisted bib" do
        post :create, params: { bib: attributes }

        expect(assigns(:bib)).to be_persisted
        expect(assigns(:bib).name).to eq(attributes[:name])
        expect(assigns(:bib).author_ids).to eq([author.id])
      end
    end

    describe "with invalid attributes" do
      let(:attributes) { { name: "", doi: "", entry_type: "misc", author_ids: [] } }

      before { allow_any_instance_of(Bib).to receive(:save).and_return(false) }

      it { expect { post :create, params: { bib: attributes } }.not_to change(Bib, :count) }

      it "assigns an unsaved bib" do
        post :create, params: { bib: attributes }

        expect(assigns(:bib)).to be_new_record
        expect(assigns(:bib).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:author) { FactoryBot.create(:author, name: "Update Author") }
    let(:bib) { FactoryBot.create(:bib, name: "bib", doi: "", authors: [author]) }
    let(:attributes) { { name: "updated_bib", doi: "", entry_type: "misc" } }

    before { put :update, params: { id: bib.id, bib: attributes } }

    it { expect(assigns(:bib)).to eq bib }
    it { expect(assigns(:bib).name).to eq attributes[:name] }
    it { expect(response).to redirect_to(bib_path(bib)) }
  end

  describe "DELETE destroy" do
    let(:author) { FactoryBot.create(:author, name: "Delete Author") }
    let!(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }

    it { expect { delete :destroy, params: { id: bib.id } }.to change(Bib, :count).by(-1) }
  end
end