require "spec_helper"

describe "global id form flows", type: :request do
  let(:user) { FactoryBot.create(:user_foo, administrator: false, password: "password", password_confirmation: "password") }

  before do
    sign_in user
  end

  after do
    User.current = nil
  end

  describe "POST /stones" do
    let!(:parent_stone) do
      User.current = user
      FactoryBot.create(:stone, name: "Parent Stone")
    end

    let!(:place) do
      User.current = user
      FactoryBot.create(:place, is_parent: true, name: "Flow Place")
    end

    let!(:box) do
      User.current = user
      FactoryBot.create(:box, name: "Flow Box")
    end

    let!(:collection) do
      User.current = user
      FactoryBot.create(:collection, name: "Flow Collection")
    end

    let!(:classification) { FactoryBot.create(:classification) }
    let!(:physical_form) { FactoryBot.create(:physical_form) }
    let!(:stonecontainer_type) { FactoryBot.create(:stonecontainer_type) }

    let(:params) do
      {
        stone: {
          name: "Created From Global IDs",
          parent_global_id: parent_stone.global_id,
          place_global_id: place.global_id,
          box_global_id: box.global_id,
          collection_global_id: collection.global_id,
          classification_id: classification.id,
          physical_form_id: physical_form.id,
          stonecontainer_type_id: stonecontainer_type.id,
          date: Date.current,
          quantity_initial: 1,
          sampledepth: 0
        }
      }
    end

    it "creates a stone wired through global ids" do
      expect {
        post stones_path, params: params
      }.to change(Stone, :count).by(1)

      created_stone = Stone.order(:id).last
      expect(created_stone.parent).to eq(parent_stone)
      expect(created_stone.place).to eq(place)
      expect(created_stone.box).to eq(box)
      expect(created_stone.collection).to eq(collection)
    end
  end

  describe "POST /analyses" do
    let!(:stone) do
      User.current = user
      FactoryBot.create(:stone, name: "Analysis Target Stone")
    end

    let!(:technique) { FactoryBot.create(:technique) }
    let!(:device) { FactoryBot.create(:device) }

    let(:params) do
      {
        analysis: {
          name: "Created From Stone Global ID",
          operator: "Spec Operator",
          stone_global_id: stone.global_id,
          technique_id: technique.id,
          device_id: device.id
        }
      }
    end

    it "creates an analysis linked by stone_global_id" do
      expect {
        post analyses_path, params: params
      }.to change(Analysis, :count).by(1)

      created_analysis = Analysis.order(:id).last
      expect(created_analysis.stone).to eq(stone)
      expect(created_analysis.technique).to eq(technique)
      expect(created_analysis.device).to eq(device)
    end
  end
end