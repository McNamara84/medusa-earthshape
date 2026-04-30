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

    describe "with DOI metadata available" do
      let!(:existing_author) { FactoryBot.create(:author, name: "Existing, Author") }
      let(:metadata) { instance_double(CrossrefHelper::Metadata) }
      let(:doi) { "10.1000/example" }
      let(:attributes) { { name: "", doi: doi, entry_type: "misc", author_ids: [] } }
      let(:permitted_attributes) { ActionController::Parameters.new(attributes).permit! }

      before do
        allow(controller).to receive(:bib_params).and_return(permitted_attributes)
        allow(CrossrefHelper::Metadata).to receive(:new).with(pid: "accountname", doi: doi).and_return(metadata)
        allow(metadata).to receive(:result?).and_return(true)
        allow(metadata).to receive(:authors).and_return(
          [
            { surname: "Existing", given_name: "Author" },
            { surname: "New", given_name: "Writer" }
          ]
        )
        allow(metadata).to receive(:title).and_return("Fetched Title")
        allow(metadata).to receive(:published).and_return(year: "2024", month: "05")
        allow(metadata).to receive(:journal).and_return(
          month: "05",
          full_title: "Journal of Testing",
          volume: "12",
          first_page: "10",
          last_page: "20"
        )
      end

      it "creates missing authors and populates the bib from DOI metadata" do
        expect { post :create, params: { bib: attributes } }
          .to change(Bib, :count).by(1)
          .and change(Author, :count).by(1)

        created_bib = assigns(:bib).reload
        expect(created_bib).to be_persisted
        expect(created_bib.name).to eq("Fetched Title")
        expect(created_bib.year).to eq("2024")
        expect(created_bib.month).to eq("05")
        expect(created_bib.journal).to eq("Journal of Testing")
        expect(created_bib.link_url).to eq("http://doi.org/#{doi}")
        expect(created_bib.volume).to eq("12")
        expect(created_bib.pages).to eq("10-20")
        expect(created_bib.authors.pluck(:name)).to contain_exactly("Existing, Author", "New, Writer")
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

  describe "GET picture" do
    let(:author) { FactoryBot.create(:author, name: "Picture Author") }
    let(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }

    before { get :picture, params: { id: bib.id } }

    it { expect(assigns(:bib)).to eq bib }
  end

  describe "GET property" do
    let(:author) { FactoryBot.create(:author, name: "Property Author") }
    let(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }

    before { get :property, params: { id: bib.id } }

    it { expect(assigns(:bib)).to eq bib }
  end

  describe "POST bundle_edit" do
    let(:author) { FactoryBot.create(:author, name: "Bundle Edit Author") }
    let(:bib_1) { FactoryBot.create(:bib, name: "bib_1", doi: "", authors: [author]) }
    let(:bib_2) { FactoryBot.create(:bib, name: "bib_2", doi: "", authors: [author]) }
    let(:bib_3) { FactoryBot.create(:bib, name: "bib_3", doi: "", authors: [author]) }
    let(:ids) { [bib_1.id, bib_2.id] }

    before do
      bib_1
      bib_2
      bib_3
      post :bundle_edit, params: { ids: ids }
    end

    it { expect(assigns(:bibs)).to include(bib_1, bib_2) }
    it { expect(assigns(:bibs)).not_to include(bib_3) }
  end

  describe "POST bundle_update" do
    let(:author) { FactoryBot.create(:author, name: "Bundle Update Author") }
    let(:original_name) { "bib_3" }
    let(:bib_1) { FactoryBot.create(:bib, name: "bib_1", doi: "", authors: [author]) }
    let(:bib_2) { FactoryBot.create(:bib, name: "bib_2", doi: "", authors: [author]) }
    let(:bib_3) { FactoryBot.create(:bib, name: original_name, doi: "", authors: [author]) }
    let(:attributes) { { name: "updated_bib", doi: "", entry_type: "misc" } }
    let(:ids) { [bib_1.id, bib_2.id] }

    before do
      bib_1
      bib_2
      bib_3
      post :bundle_update, params: { ids: ids, bib: attributes }
      bib_1.reload
      bib_2.reload
      bib_3.reload
    end

    it { expect(bib_1.name).to eq(attributes[:name]) }
    it { expect(bib_2.name).to eq(attributes[:name]) }
    it { expect(bib_3.name).to eq(original_name) }
  end

  describe "GET download_bundle_card" do
    let(:author) { FactoryBot.create(:author, name: "Bundle Card Author") }
    let(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }
    let(:params_ids) { [bib.id.to_s] }
    let(:bibs) { Bib.where(id: params_ids) }
    let(:report) { instance_double("Report") }
    let(:generated_pdf) { "pdf-data" }

    before do
      bib
      allow(Bib).to receive(:where).and_return(bibs)
      allow(Bib).to receive(:build_cards).with(bibs).and_return(report)
      allow(report).to receive(:generate).and_return(generated_pdf)
      allow(controller).to receive(:send_data) { controller.response_body = "" }
    end

    it "sends the generated bundle PDF" do
      expect(controller).to receive(:send_data).with(generated_pdf, filename: "bibs.pdf", type: "application/pdf")

      get :download_bundle_card, params: { ids: params_ids }
    end
  end

  describe "GET download_label" do
    let(:author) { FactoryBot.create(:author, name: "Label Author") }
    let(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }
    let(:label) { "label-data" }

    before do
      allow(Bib).to receive(:find).with(bib.id.to_s).and_return(bib)
      allow(bib).to receive(:build_label).and_return(label)
      allow(controller).to receive(:send_data) { controller.response_body = "" }
    end

    it "sends the generated CSV" do
      expect(controller).to receive(:send_data).with(label, filename: "bib_#{bib.id}.csv", type: "text/csv")

      get :download_label, params: { id: bib.id }
    end
  end

  describe "GET download_bundle_label" do
    let(:author) { FactoryBot.create(:author, name: "Bundle Label Author") }
    let(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }
    let(:params_ids) { [bib.id.to_s] }
    let(:bibs) { Bib.where(id: params_ids) }
    let(:label) { "label-data" }

    before do
      bib
      allow(Bib).to receive(:where).and_return(bibs)
      allow(Bib).to receive(:build_bundle_label).with(bibs).and_return(label)
      allow(controller).to receive(:send_data) { controller.response_body = "" }
    end

    it "sends the generated bundle CSV" do
      expect(controller).to receive(:send_data).with(label, filename: "bibs.csv", type: "text/csv")

      get :download_bundle_label, params: { ids: params_ids }
    end
  end

  describe "GET download_to_tex" do
    let(:author) { FactoryBot.create(:author, name: "Tex Author") }
    let(:bib) { FactoryBot.create(:bib, doi: "", authors: [author]) }
    let(:params_ids) { [bib.id.to_s] }
    let(:bibs) { Bib.where(id: params_ids) }
    let(:tex) { "@article{demo}" }

    before do
      bib
      allow(Bib).to receive(:where).and_return(bibs)
      allow(Bib).to receive(:build_bundle_tex).with(bibs).and_return(tex)
      allow(controller).to receive(:send_data) { controller.response_body = "" }
    end

    it "sends the generated bibtex export" do
      expect(controller).to receive(:send_data).with(tex, filename: "bibs.bib", type: "text")

      get :download_to_tex, params: { ids: params_ids }
    end
  end
end