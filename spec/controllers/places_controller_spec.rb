require 'spec_helper'
include ActionDispatch::TestProcess

describe PlacesController do
  let(:user) { FactoryBot.create(:user, :username => "user_1") }
  before { sign_in user }

  describe "GET index" do
    let(:place_1) { FactoryBot.create(:place, :name => "place_1") }
    let(:place_2) { FactoryBot.create(:place, :name => "place_2") }
    let(:place_3) { FactoryBot.create(:place, :name => "hoge") }
    let(:record_property_1) { RecordProperty.find_by(datum_id: place_1.id) }
    let(:record_property_2) { RecordProperty.find_by(datum_id: place_2.id) }
    let(:record_property_3) { RecordProperty.find_by(datum_id: place_3.id) }
    let(:user_2) { FactoryBot.create(:user, :username => "test_2", :email => "email@test_2.co.jp") }
    let(:user_3) { FactoryBot.create(:user, :username => "test_3", :email => "email@hoge.co.jp") }
    let(:group_1) { FactoryBot.create(:group, :name => "group_1") }
    let(:group_2) { FactoryBot.create(:group, :name => "hoge") }
    let(:group_3) { FactoryBot.create(:group, :name => "group_3") }
    let(:params) { {q: query} }

    let(:stone_1) { FactoryBot.create(:stone, name: "hoge", place_id: place_1.id) }
    let(:stone_2) { FactoryBot.create(:stone, name: "stone_2", place_id: place_2.id) }
    let(:stone_3) { FactoryBot.create(:stone, name: "stone_3", place_id: place_3.id) }
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
      # Ensure all groups are created first (force eager evaluation)
      group_1
      group_2
      group_3
      # Ensure all users are created
      user_2
      user_3
      # Create places and their dependencies
      place_1
      place_2
      place_3
      stone_1;stone_2;stone_3;      
      analysis_1;analysis_2;analysis_3;
      # Explicitly set permissions - reload to ensure fresh data
      # place_1 owned by current user, group_1
      record_property_1.reload.update!(user_id: user.id, group_id: group_1.id, owner_readable: true, owner_writable: true)
      # place_2 owned by user_2, guest readable
      record_property_2.reload.update!(user_id: user_2.id, group_id: group_2.id, guest_readable: true, guest_writable: true, owner_readable: true, owner_writable: true)
      # place_3 owned by user_3, guest readable
      record_property_3.reload.update!(user_id: user_3.id, group_id: group_3.id, guest_readable: true, guest_writable: true, owner_readable: true, owner_writable: true)
    end
    describe "search" do
      before do
        get :index, params: params
      end
      context "name search" do
        let(:query) { {"name_cont" => "place"} }
        it { expect(assigns(:places).to_a).to match_array [place_2, place_1] }
      end
      context "owner search" do
        let(:query) { {"user_username_cont" => "test"} }
        it { expect(assigns(:places).to_a).to match_array [place_3, place_2] }
      end
      context "group search" do
        let(:query) { {"group_name_cont" => "group"} }
        it { expect(assigns(:places).to_a).to match_array [place_3, place_1] }
      end
    end
    describe "sort" do
      before do
        get :index, params: params
      end

      let(:params) { {q: query, page: 2, per_page: 1} }
      context "sort condition is present" do
        let(:query) { {"name_cont" => "place", "s" => "updated_at DESC"} }
        it { expect(assigns(:places)).to eq [place_1] }
      end
      context "sort condition is nil" do
        let(:query) { {"name_cont" => "place"} }
        it { expect(assigns(:places)).to eq [place_1] }
      end
    end

    context "with format 'pml'" do
      before do
        get :index, format: 'pml'
      end
      it { expect(response.body).to include("\<sample_global_id\>#{stone_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_3.global_id}") } 
    end
  end

  # send_data test returns unexpected object.
  describe "GET new" do
  end

  describe "GET show" do
    let(:obj){FactoryBot.create(:place) }
    let(:stone_1) { FactoryBot.create(:stone, name: "hoge", place_id: obj.id) }
    let(:stone_2) { FactoryBot.create(:stone, name: "stone_2", place_id: obj.id) }
    let(:stone_3) { FactoryBot.create(:stone, name: "stone_3", place_id: obj.id) }
    let(:analysis_1) do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_1.stones << stone_1
      analysis_1
    end
    let(:analysis_2) do
      analysis_2 = FactoryBot.create(:analysis)
      analysis_2.stones << stone_2
      analysis_2
    end
    let(:analysis_3) do
      analysis_3 = FactoryBot.create(:analysis)
      analysis_3.stones << stone_3
      analysis_3
    end
    before do
      stone_1;stone_2;stone_3;      
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do    
      before{get :show, params: {id: obj.id}}
      it{expect(assigns(:place)).to eq obj}
      it{expect(response).to render_template("show") }
    end

    context "with format 'pml'" do
      before { get :show, params: {id: obj.id}, format: 'pml' }
      it { expect(response.body).to include("\<sample_global_id\>#{stone_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_3.global_id}") }    
    end

  end

  describe "GET edit" do
    let(:place) { FactoryBot.create(:place) }
    before { get :edit, params: {id: place.id} }
    it { expect(assigns(:place)).to eq place }
  end

  describe "POST create" do
    let(:attributes) { {name: "place_name", latitude: "1.0", longitude: "2.0", elevation: "0", is_parent: true} }
    it { expect {post :create, params: {place: attributes}}.to change(Place, :count).by(1) }
    context "create" do
      before{post :create, params: {place: attributes}}
      it{expect(assigns(:place).name).to eq attributes[:name]}
    end
  end

  describe "PUT update" do
    let(:obj){FactoryBot.create(:place) }
    let(:attributes) { {name: "update_name", latitude: "1.0", longitude: "2.0", elevation: "0"} }
    it { expect {put :update, params: {id: obj.id, place: attributes}}.to change(Place, :count).by(0) }
    before do
      obj
      put :update, params: {id: obj.id, place: attributes}
    end
    it{expect(assigns(:place).name).to eq attributes[:name]}
  end

  describe "GET map" do
    let(:obj){FactoryBot.create(:place) }
    before{get :map, params: {id: obj.id}}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("map") }
  end

  describe "GET property" do
    let(:obj){FactoryBot.create(:place) }
    before{get :property, params: {id: obj.id}}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("property") }
  end

  describe "DELETE destroy" do
    let(:obj){FactoryBot.create(:place) }
    before { obj }
    it { expect{delete :destroy, params: {id: obj.id}}.to change(Place, :count).by(-1) }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryBot.create(:place, name: "obj1") }
    let(:obj2) { FactoryBot.create(:place, name: "obj2") }
    let(:obj3) { FactoryBot.create(:place, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, params: {ids: ids}
    end
    it {expect(assigns(:places).include?(obj1)).to be_truthy}
    it {expect(assigns(:places).include?(obj2)).to be_truthy}
    it {expect(assigns(:places).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryBot.create(:place, name: "obj1") }
    let(:obj2) { FactoryBot.create(:place, name: "obj2") }
    let(:obj3) { FactoryBot.create(:place, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, params: {ids: ids, place: attributes}
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end
  
  describe "GET download_bundle_card" do
    # send_data
  end
  
  # send_data test returns unexpected object. Skip to avoid "FIXED" error.
  xit "GET download_label" do
  end
  
  describe "GET download_bundle_label" do
    let(:place) { FactoryBot.create(:place) }
    let(:params_ids) { [place.id.to_s] }
    let(:label) { double(:label) }
    let(:places) { Place.all }
    before do
      place
      allow(Place).to receive(:where).and_return(places)
      allow(Place).to receive(:build_bundle_label).and_return(label)
    end
    it "sends bundle label data" do
      allow(controller).to receive(:send_data) { controller.response_body = '' }
      expect(controller).to receive(:send_data).with(label, filename: "places.csv", type: "text/csv")
      get :download_bundle_label, params: {ids: params_ids}
    end
  end

  describe "POST import" do
    let(:data) { double(:upload_data) }
    context "return raise" do
      before do
        allow(Place).to receive(:import_csv).with(data.to_s).and_raise("error")
        post :import, params: {data: data}
      end
      it { expect(response).to render_template("import_invalid") }
    end
    context "return no error" do
      before do
        allow(Place).to receive(:import_csv).with(data.to_s).and_return(import_result)
        post :import, params: {data: data}
      end
      context "import success" do
        let(:import_result) { true }
        it { expect(response).to redirect_to(places_path) }
      end
      context "import false" do
        let(:import_result) { false }
        it { expect(response).to render_template("import_invalid") }
      end
    end
  end

end
