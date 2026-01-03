require 'spec_helper'

describe NestedResources::PreparationsController do
  let(:parent_name) { :stone }
  let(:child_name) { :preparation }
  let(:parent) { FactoryBot.create(parent_name) }
  let(:child) { FactoryBot.create(child_name, :with_preparation_type, stone: parent) }
  let(:user) { FactoryBot.create(:user) }
  let(:url) { "http://test.host/where_i_came_from" }
  let(:preparation_type) { FactoryBot.create(:preparation_type) }
  let(:attributes) { { info: "New preparation info", preparation_type_id: preparation_type.id } }
  
  before { request.env["HTTP_REFERER"] = url }
  before { sign_in user }
  before { parent }

  describe "POST create" do
    let(:method) { post :create, params: { parent_resource: parent_name, stone_id: parent, preparation: attributes, association_name: :preparations } }
    
    it "creates a new preparation" do
      expect { method }.to change(Preparation, :count).by(1)
    end

    context "with valid attributes" do
      before { method }
      
      it "associates the preparation with the parent stone" do
        expect(parent.preparations.exists?(info: "New preparation info")).to eq true
      end
      
      it "sets the preparation_type" do
        expect(parent.preparations.last.preparation_type_id).to eq preparation_type.id
      end
      
      it "redirects to referer" do
        expect(response).to redirect_to request.env["HTTP_REFERER"]
      end
    end

    context "without preparation_type (optional)" do
      let(:attributes) { { info: "Preparation without type" } }
      
      it "creates a preparation without preparation_type" do
        expect { method }.to change(Preparation, :count).by(1)
      end
      
      it "has nil preparation_type_id" do
        method
        expect(parent.preparations.last.preparation_type_id).to be_nil
      end
    end

    context "without stone (testing model optionality)" do
      it "allows preparation to be created without stone via model" do
        preparation = FactoryBot.build(:preparation, stone: nil)
        expect(preparation).to be_valid
      end
    end

    context "with invalid attributes" do
      # Since Preparation currently has no required validations,
      # we simulate a validation failure by stubbing valid? to return false
      before do
        allow_any_instance_of(Preparation).to receive(:valid?).and_return(false)
        allow_any_instance_of(Preparation).to receive_message_chain(:errors, :empty?).and_return(false)
        method
      end
      
      it "does not create a new preparation" do
        # Note: The first call already happened in before block
        # We need to check count didn't change during that first call
        initial_count = Preparation.count
        post :create, params: { parent_resource: parent_name, stone_id: parent, preparation: attributes, association_name: :preparations }
        expect(Preparation.count).to eq initial_count
      end
      
      it "renders error template" do
        expect(response).to render_template("error")
      end
    end
  end

  describe "DELETE destroy" do
    let(:method) { delete :destroy, params: { parent_resource: parent_name, stone_id: parent, id: child_id, association_name: :preparations } }
    let(:child_id) { child.id }
    
    before { child } # ensure child exists before delete
    
    it "deletes the preparation" do
      child # ensure child exists
      expect { method }.to change(Preparation, :count).by(-1)
    end

    context "with existing child" do
      before { method }
      
      it "removes preparation from parent" do
        expect(parent.preparations.exists?(id: child.id)).to eq false
      end
      
      it "redirects to referer" do
        expect(response).to redirect_to request.env["HTTP_REFERER"]
      end
    end

    context "with non-existent child" do
      let(:child_id) { 0 }
      
      it "raises RecordNotFound" do
        expect { method }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
