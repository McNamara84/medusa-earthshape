require "spec_helper"

describe Preparation do
  let(:user) { FactoryBot.create(:user) }
  before { User.current = user }

  describe "associations" do
    describe "belongs_to stone" do
      let(:stone) { FactoryBot.create(:stone) }
      let(:preparation) { FactoryBot.create(:preparation, stone: stone) }
      
      it "is associated with a stone" do
        expect(preparation.stone).to eq stone
      end
    end

    describe "belongs_to preparation_type" do
      let(:preparation_type) { FactoryBot.create(:preparation_type) }
      let(:preparation) { FactoryBot.create(:preparation, preparation_type: preparation_type) }
      
      it "is associated with a preparation_type" do
        expect(preparation.preparation_type).to eq preparation_type
      end
    end
  end

  describe "optional associations" do
    describe "stone is optional" do
      let(:preparation) { Preparation.new(info: "Test without stone") }
      
      it "is valid without a stone" do
        expect(preparation).to be_valid
      end
      
      it "saves without a stone" do
        expect(preparation.save).to be true
        expect(preparation.stone_id).to be_nil
      end
    end

    describe "preparation_type is optional" do
      let(:stone) { FactoryBot.create(:stone) }
      let(:preparation) { Preparation.new(info: "Test without type", stone: stone) }
      
      it "is valid without a preparation_type" do
        expect(preparation).to be_valid
      end
      
      it "saves without a preparation_type" do
        expect(preparation.save).to be true
        expect(preparation.preparation_type_id).to be_nil
      end
    end
  end

  describe "creating via association" do
    let(:stone) { FactoryBot.create(:stone) }
    
    describe "using build on association" do
      it "automatically sets stone_id" do
        preparation = stone.preparations.build(info: "Built via association")
        expect(preparation.stone_id).to eq stone.id
      end

      it "saves successfully when built via association" do
        preparation = stone.preparations.build(info: "Built via association")
        expect(preparation.save).to be true
        expect(preparation.persisted?).to be true
      end

      it "is included in stone.preparations after save" do
        preparation = stone.preparations.build(info: "Built via association")
        preparation.save
        expect(stone.preparations.reload).to include(preparation)
      end
    end

    describe "with preparation_type" do
      let(:preparation_type) { FactoryBot.create(:preparation_type) }
      
      it "saves with both stone and preparation_type" do
        preparation = stone.preparations.build(info: "With type", preparation_type: preparation_type)
        expect(preparation.save).to be true
        expect(preparation.stone_id).to eq stone.id
        expect(preparation.preparation_type_id).to eq preparation_type.id
      end
    end

    describe "without preparation_type" do
      it "saves with stone but without preparation_type" do
        preparation = stone.preparations.build(info: "Without type", preparation_type: nil)
        expect(preparation.save).to be true
        expect(preparation.stone_id).to eq stone.id
        expect(preparation.preparation_type_id).to be_nil
      end
    end
  end
end
