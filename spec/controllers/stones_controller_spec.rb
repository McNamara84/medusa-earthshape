require 'spec_helper'
include ActionDispatch::TestProcess

describe StonesController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:stone_1) { FactoryBot.create(:stone, name: "hoge") }
    let(:stone_2) { FactoryBot.create(:stone, name: "stone_2") }
    let(:stone_3) { FactoryBot.create(:stone, name: "stone_3") }
    let(:analysis_1) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone_1
      analysis
    end
    let(:analysis_2) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone_2
      analysis
    end
    let(:analysis_3) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone_3
      analysis
    end
    before do
      stone_1;stone_2;stone_3
      get :index
    end
    it { expect(assigns(:stones).count).to eq 3 }

    context "with format 'json'" do
      before do
        stone_1;stone_2;stone_3
        analysis_1;analysis_2;analysis_3;
        get :index, format: 'json'
      end
      it { expect(response.body).to include("\"global_id\":") }    
    end

    context "with format 'pml'" do
      before do
        stone_1;stone_2;stone_3
        analysis_1;analysis_2;analysis_3;

        get :index, format: 'pml'
      end
      it { expect(response.body).to include("\<sample_global_id\>#{stone_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_3.global_id}") }    
    end

  end
  
  describe "GET show", :current => true do
    let(:stone) { FactoryBot.create(:stone) }
    let(:analysis_1) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone
      analysis
    end
    let(:analysis_2) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone
      analysis
    end
    let(:analysis_3) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone
      analysis
    end
    before do
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do
      before { get :show, params: {id: stone.id} }
      it { expect(assigns(:stone)).to eq stone }
    end

    context "with format 'json'" do
      before { get :show, params: {id: stone.id}, format: 'json' }
      it { expect(response.body).to include("\"global_id\":") }    
    end

    context "with format 'pml'" do
      before { get :show, params: {id: stone.id}, format: 'pml' }
      it { expect(response.body).to include("\<sample_global_id\>#{stone.global_id}") }    
    end

  end
  
  describe "GET edit" do
    let(:stone) { FactoryBot.create(:stone) }
    before { get :edit, params: {id: stone.id} }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "POST create" do
    let(:place) { FactoryBot.create(:place) }
    let(:box) { FactoryBot.create(:box) }
    let(:collection) { FactoryBot.create(:collection) }
    let(:stonecontainer_type) { FactoryBot.create(:stonecontainer_type) }
    let(:classification) { FactoryBot.create(:classification) }
    let(:physical_form) { FactoryBot.create(:physical_form) }
    let(:attributes) do
      {
        name: "stone_name",
        place_id: place.id,
        box_id: box.id,
        collection_id: collection.id,
        stonecontainer_type_id: stonecontainer_type.id,
        classification_id: classification.id,
        physical_form_id: physical_form.id,
        date: Date.today,
        quantity_initial: 1,
        sampledepth: 0
      }
    end
    it { expect { post :create, params: {stone: attributes} }.to change(Stone, :count).by(1) }
    describe "assigns as @stone" do
      before { post :create, params: {stone: attributes} }
      it { expect(assigns(:stone)).to be_persisted }
      it { expect(assigns(:stone).name).to eq "stone_name"}
    end
  end
  
  describe "PUT update" do
    before do
      stone
    end
    let(:stone) { FactoryBot.create(:stone) }
    let(:attributes) { {name: "update_name"} }
    context "witout format" do
      before { put :update, params: {id: stone.id, stone:attributes} }
      it { expect(assigns(:stone)).to eq stone }
      it { expect(assigns(:stone).name).to eq attributes[:name] }
    end
  end

  describe "DELETE destroy" do
    let(:stone) { FactoryBot.create(:stone) }
    before { stone }
    it { expect { delete :destroy, params: {id: stone.id} }.to change(Stone, :count).by(-1) }
  end
  
  describe "GET family" do
    let(:stone) { FactoryBot.create(:stone) }
    before { get :family, params: {id: stone.id} }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "GET picture" do
    let(:stone) { FactoryBot.create(:stone) }
    before { get :picture, params: {id: stone.id} }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "GET map" do
    let(:stone) { FactoryBot.create(:stone) }
    before { get :map, params: {id: stone.id} }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "GET property" do
    let(:stone) { FactoryBot.create(:stone) }
    before { get :property, params: {id: stone.id} }
    it { expect(assigns(:stone)).to eq stone }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryBot.create(:stone, name: "obj1") }
    let(:obj2) { FactoryBot.create(:stone, name: "obj2") }
    let(:obj3) { FactoryBot.create(:stone, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, params: {ids: ids}
    end
    it {expect(assigns(:stones).include?(obj1)).to be_truthy}
    it {expect(assigns(:stones).include?(obj2)).to be_truthy}
    it {expect(assigns(:stones).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryBot.create(:stone, name: "obj1") }
    let(:obj2) { FactoryBot.create(:stone, name: "obj2") }
    let(:obj3) { FactoryBot.create(:stone, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, params: {ids: ids, stone: attributes}
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end

  describe "GET download_card" do
    let(:owner) { FactoryBot.create(:user, email: "owner-download-card@example.com", username: "owner_download_card", prefix: "GFABC") }
    let(:stone) { FactoryBot.create(:stone, user: owner, igsn: igsn) }
    let(:report) { instance_double("Report") }
    let(:generated_pdf) { "pdf-data" }
    let(:igsn) { "IGSN-001" }

    before do
      allow(Stone).to receive(:find).with(stone.id.to_s).and_return(stone)
      allow(stone).to receive(:build_igsn_card).and_return(report)
      allow(report).to receive(:generate).and_return(generated_pdf)
      allow(controller).to receive(:send_data) { controller.response_body = "" }
    end

    it "sends the generated PDF" do
      expect(controller).to receive(:send_data).with(generated_pdf, filename: "sample.pdf", type: "application/pdf")

      get :download_card, params: {id: stone.id}
    end

    context "when the stone has no igsn yet" do
      let(:igsn) { nil }

      before do
        allow(stone).to receive(:create_igsn)
        allow(stone).to receive(:save).and_return(true)
      end

      it "creates an igsn before generating the PDF" do
        expect(stone).to receive(:create_igsn).with(owner.prefix, stone)
        expect(stone).to receive(:save)

        get :download_card, params: {id: stone.id}
      end
    end

    context "when the owner has no igsn prefix" do
      let(:owner) { FactoryBot.create(:user, email: "owner-download-card-no-prefix@example.com", username: "owner_download_card_no_prefix", prefix: nil) }

      it "renders the missing-prefix warning" do
        get :download_card, params: {id: stone.id}

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET download_bundle_card" do
    let(:owner) { FactoryBot.create(:user, email: "owner-download-bundle-card@example.com", username: "owner_download_bundle_card", prefix: "GFABC") }
    let(:stone) { FactoryBot.create(:stone, user: owner, igsn: nil) }
    let(:stones) { [stone] }
    let(:params_ids) { [stone.id.to_s] }
    let(:report) { instance_double("Report") }
    let(:generated_pdf) { "pdf-data" }

    before do
      stone
      allow(Stone).to receive(:where).and_return(stones)
      allow(stone).to receive(:create_igsn)
      allow(stone).to receive(:save).and_return(true)
      allow(Stone).to receive(:build_igsn_a_four).with(stones).and_return(report)
      allow(report).to receive(:generate).and_return(generated_pdf)
      allow(controller).to receive(:send_data) { controller.response_body = "" }
    end

    it "creates missing igsns and sends the bundle PDF" do
      expect(stone).to receive(:create_igsn).with(owner.prefix, stone)
      expect(stone).to receive(:save)
      expect(controller).to receive(:send_data).with(generated_pdf, filename: "samples.pdf", type: "application/pdf")

      get :download_bundle_card, params: {ids: params_ids, a4: "true"}
    end
  end

  describe "GET igsn_create" do
    let(:owner) { FactoryBot.create(:user, email: owner_email, username: owner_username, prefix: prefix) }
    let(:stone) { FactoryBot.create(:stone, user: owner, igsn: nil) }
    let(:prefix) { "GFABC" }
    let(:owner_email) { "owner-igsn-create@example.com" }
    let(:owner_username) { "owner_igsn_create" }

    before do
      allow(Stone).to receive(:find).with(stone.id.to_s).and_return(stone)
    end

    context "when the owner has an igsn prefix" do
      before do
        allow(stone).to receive(:create_igsn)
        allow(stone).to receive(:save).and_return(true)
      end

      it "creates an igsn and redirects to the stone" do
        expect(stone).to receive(:create_igsn).with(owner.prefix, stone)
        expect(stone).to receive(:save)

        get :igsn_create, params: {id: stone.id}

        expect(response).to redirect_to(stone_path(stone))
      end
    end

    context "when the owner has no igsn prefix" do
      let(:prefix) { nil }
      let(:owner_email) { "owner-igsn-create-no-prefix@example.com" }
      let(:owner_username) { "owner_igsn_create_no_prefix" }

      it "renders the missing-prefix warning" do
        get :igsn_create, params: {id: stone.id}

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET igsn_register" do
    let(:non_admin) { FactoryBot.create(:user, email: "stone-igsn-register-non-admin@example.com", username: "stone_igsn_register_non_admin", administrator: false) }
    let(:stone) { FactoryBot.create(:stone) }

    before do
      sign_out user
      sign_in non_admin
    end

    it "rejects non-admin users" do
      get :igsn_register, params: {id: stone.id}

      expect(flash[:error]).to eq("Only administrators can register IGSNs")
      expect(response).to redirect_to(stone_url(stone))
    end
  end
  
  describe "GET download_label" do
    let(:stone) { FactoryBot.create(:stone, name: "sample-name") }
    let(:label) { "label-data" }

    before do
      allow(Stone).to receive(:find).with(stone.id.to_s).and_return(stone)
      allow(stone).to receive(:build_label).and_return(label)
      allow(controller).to receive(:send_data) { controller.response_body = "" }
    end

    it "sends the generated CSV" do
      expect(controller).to receive(:send_data).with(label, filename: "sample_sample-name.csv", type: "text/csv")

      get :download_label, params: {id: stone.id}
    end
  end
  
  describe "download_bundle_label" do
    let(:stone) { FactoryBot.create(:stone) }
    let(:params_ids) { [stone.id.to_s] }
    let(:label) { double(:label) }
    let(:stones) { Stone.all }
    before do
      stone
      allow(Stone).to receive(:where).and_return(stones)
      allow(Stone).to receive(:build_bundle_label).and_return(label)
    end
    it "sends bundle label data" do
      allow(controller).to receive(:send_data) { controller.response_body = '' }
      expect(controller).to receive(:send_data).with(label, filename: "samples.csv", type: "text/csv")
      get :download_bundle_label, params: {ids: params_ids}
    end
  end
  
end
