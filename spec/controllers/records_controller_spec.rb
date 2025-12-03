require 'spec_helper'

describe RecordsController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:stone) { FactoryBot.create(:stone) }
    let(:box) { FactoryBot.create(:box) }
    let(:analysis) { FactoryBot.create(:analysis) }
    let(:bib) { FactoryBot.create(:bib) }
    let(:place) { FactoryBot.create(:place) }
    # Use :with_real_file for JSON format tests (as_json calls path methods that need real file)
    let(:attachment_file) { FactoryBot.create(:attachment_file, :with_real_file) }
    # Count only record_properties that are readable by current user
    # instead of all objects in the database
    let(:allcount) { RecordProperty.readables(user).where.not(datum_type: ["Chemistry", "Spot", "Staging"]).count }
    before do
      User.current = user  # Ensure User.current is set for record_property creation
      stone
      box
      analysis
      bib
      place
      attachment_file
#      get :index
    end

    context "without format" do
      before do
        get :index
      end
      it { expect(assigns(:records_search).class).to eq Ransack::Search }
      it { expect(assigns(:records).size).to eq(allcount) }
    end

    context "with format json" do
      before do
        get :index, format: 'json'
      end
      it { expect(assigns(:records).size).to eq(allcount) }
      it { expect(response.body).to include("\"global_id\":") }
      it { expect(response.body).to include("\"datum_id\":") }      
      it { expect(response.body).to include("\"datum_type\":") }      
      it { expect(response.body).to include("\"datum_attributes\":") }      

    end

    context "with format pml" do
      before do
        get :index, format: 'pml'
      end
      it { expect(assigns(:records).size).to eq(allcount) }
      it { expect(response.body).to include("\<global_id\>#{analysis.global_id}") }    

    end

  end

  describe "GET show" do

    context "record found json " do
      let(:stone) { FactoryBot.create(:stone) }
      before do
        stone
        get :show, params: {id: stone.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include(stone.to_json) }
    end
    context "record found html " do
      let(:stone) { FactoryBot.create(:stone) }
      before do
        stone
        get :show, params: {id: stone.record_property.global_id}, format: :html
      end
      it { expect(response).to  redirect_to(controller: "stones",action: "show",id:stone.id) }
    end
    context "record found pml " do
      let(:stone) { FactoryBot.create(:stone) }
      let(:analysis) do
        analysis = FactoryBot.create(:analysis)
        analysis.stones << stone
        analysis
      end
      before do
        stone
        analysis
        get :show, params: {id: stone.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{stone.global_id}") }    

    end
    context "record not found json" do
      before do
        get :show, params: {id: "not_found_id"}, format: :json
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end
    context "record not found html" do
      before do
        get :show, params: {id: "not_found_id"}, format: :html
      end
      it { expect(response).to render_template("record_not_found") }
      it { expect(response.status).to eq 404 }
    end
    context "record not found pml" do
      before do
        get :show, params: {id: "not_found_id"}, format: :pml
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end

  end

  describe "GET ancestors" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << root
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_1
      analysis_3
    end
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :ancestors, params: {id: child_1_1.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :ancestors, params: {id: child_1_1.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET descendants" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << root
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_1
      analysis_3
    end
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :descendants, params: {id: root.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :descendants, params: {id: root.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET self_and_descendants" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << root
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_1
      analysis_3
    end
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :self_and_descendants, params: {id: root.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :self_and_descendants, params: {id: root.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET families" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << root
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_1
      analysis_3
    end
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :families, params: {id: child_1.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :families, params: {id: child_1.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET root" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << root
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_1
      analysis_3
    end
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :root, params: {id: child_1_1.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
    end
    context "with format json" do
      before do
        get :root, params: {id: child_1_1.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
    end
  end

  describe "GET parent" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << root
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_1
      analysis_3
    end
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :parent, params: {id: child_1_1.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :parent, params: {id: child_1_1.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }
    end
  end


  describe "GET siblings" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:child_1_2){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:child_1_3){ FactoryBot.create(:stone, parent_id: child_1.id) }

    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << child_1_1
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1_2
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_3
      analysis_3
    end
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :siblings, params: {id: child_1_1.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }    
    end
    context "with format json" do
      before do
        get :siblings, params: {id: child_1_1.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET daughters" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:child_1_2){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:child_1_3){ FactoryBot.create(:stone, parent_id: child_1.id) }

    let(:analysis_1) do

      analysis_1 = FactoryBot.create(:analysis)

      analysis_1.stones << child_1_1

      analysis_1

    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1_2
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_3
      analysis_3
    end
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :daughters, params: {id: child_1.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }    
    end
    context "with format json" do
      before do
        get :daughters, params: {id: child_1.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET self_and_siblings" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:child_1_2){ FactoryBot.create(:stone, parent_id: child_1.id) }
    let(:child_1_3){ FactoryBot.create(:stone, parent_id: child_1.id) }

    let(:analysis_1) do

      analysis_1 = FactoryBot.create(:analysis)

      analysis_1.stones << child_1_1

      analysis_1

    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << child_1_2
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << child_1_3
      analysis_3
    end
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :self_and_siblings, params: {id: child_1_1.record_property.global_id}, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }    
    end
    context "with format json" do
      before do
        get :self_and_siblings, params: {id: child_1_1.record_property.global_id}, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET property" do
    context "record found json" do
      let(:stone) { FactoryBot.create(:stone) }
      before do
        stone
        get :property, params: {id: stone.record_property.global_id}, format: :json
      end
      it { expect(response.body).to eq(stone.record_property.to_json) }
    end
    context "record found html" do
      let(:stone) { FactoryBot.create(:stone) }
      before do
        stone
        get :property, params: {id: stone.record_property.global_id}, format: :html
      end
      pending { expect(response).to render_template("") }
    end
    context "record not found json" do
      before do
        get :property, params: {id: "not_found_id"}, format: :json
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end
    context "record not found html" do
      before do
        get :property, params: {id: "not_found_id"}, format: :html
      end
      it { expect(response).to render_template("record_not_found") }
      it { expect(response.status).to eq 404 }
    end
  end
  
  describe "casteml" do
    let(:obj) { FactoryBot.create(:stone) }
    let(:analysis_1){ FactoryBot.create(:analysis, :stone_id => obj.id )}
    let(:analysis_2){ FactoryBot.create(:analysis, :stone_id => obj.id )}
    let(:casteml){[analysis_2, analysis_1].to_pml}
    before do
      obj
      analysis_1
      analysis_2      
    end
    it "sends casteml data" do
      allow(controller).to receive(:send_data) { controller.response_body = '' }
      expect(controller).to receive(:send_data).with(casteml, {type: "application/xml", filename: obj.global_id + ".pml", disposition: "attached"})
      get :casteml, params: {id: obj.global_id}
    end
  end

  describe "DELETE destroy" do
    let(:stone) { FactoryBot.create(:stone) }
    before { stone }
    it { expect { delete :destroy, params: {id: stone.record_property.global_id} }.to change(RecordProperty, :count).by(-1) }
  end
end
