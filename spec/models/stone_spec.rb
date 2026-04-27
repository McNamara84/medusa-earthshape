require "spec_helper"

describe Stone do
  describe ".to_pml", :current => true do
    let(:stone1) { FactoryBot.create(:stone) }
    let(:stone2) { FactoryBot.create(:stone) }
    let(:stones) { [stone1] }
    let(:analysis_1) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone1
      analysis
    end
    let(:analysis_2) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone1
      analysis
    end
    let(:analysis_3) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone2
      analysis
    end
    let(:analysis_4) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone2
      analysis
    end
    before do
      stone1
      stone2
      analysis_1
      analysis_2
      analysis_3
      analysis_4
    end
    it { expect(stone1.analyses.count).to eq 2}
    it { expect(stone1.to_pml).to eql([analysis_2, analysis_1].to_pml)}
    it { expect(stone2.analyses.count).to eq 2}
    it { expect(stone2.to_pml).to eql([analysis_4, analysis_3].to_pml)}
    it { expect(stones.to_pml).to eql([analysis_2, analysis_1].to_pml) }
  end

  describe ".descendants" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.descendants).to match_array([child_1, child_1_1])
    }
  end

  describe ".self_and_descendants" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1){ FactoryBot.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:stone, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.self_and_descendants).to match_array([root, child_1, child_1_1])
    }
  end

  describe "recursive helpers" do
    let(:root) { FactoryBot.create(:stone, name: "root") }
    let(:child_1) { FactoryBot.create(:stone, name: "child_1", parent_id: root.id) }
    let(:child_2) { FactoryBot.create(:stone, name: "child_2", parent_id: root.id) }
    let(:grandchild) { FactoryBot.create(:stone, name: "grandchild", parent_id: child_1.id) }

    before do
      root
      child_1
      child_2
      grandchild
    end

    it "returns ancestors from direct parent to root" do
      expect(grandchild.ancestors).to eq([child_1, root])
    end

    it "returns siblings without self" do
      expect(child_1.siblings).to match_array([child_2])
    end

    it "returns self and siblings for a child node" do
      expect(child_1.self_and_siblings).to match_array([child_1, child_2])
    end

    it "returns only self for a root node" do
      expect(root.self_and_siblings).to eq([root])
    end

    it "returns the hierarchy root" do
      expect(grandchild.root).to eq(root)
    end

    it "builds the family view for non-root nodes" do
      expect(child_1.families).to match_array([root, child_1, child_2, grandchild])
    end
  end

  describe ".blood_path" do
      let(:parent_stone) { FactoryBot.create(:stone) }
      let(:stone) { FactoryBot.create(:stone, parent_id: parent_id) }
      before do
        parent_stone
        stone
      end
      describe "parent" do
        context "us not present" do
          let(:parent_id) { nil }
           #before { stone.parent_id = parent_stone.id }
           it { expect(stone.blood_path).to eq "/#{stone.name}" }          
        end
        context "is present" do
          let(:parent_id) { parent_stone.id }
           before { stone.parent_id = parent_stone.id }
           it { expect(stone.blood_path).to eq "/#{parent_stone.name}/#{stone.name}" }          
        end
      end
  end

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryBot.build(:stone, name: name) }
      context "is presence" do
        let(:name) { "sample_obj_name" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:name) { "a" * 255 }
          it { expect(obj).to be_valid }
        end
        context "is 256 characters" do
          let(:name) { "a" * 256 }
          it { expect(obj).not_to be_valid }
        end
      end
    end
    describe "parent_id" do
      let(:parent_stone) { FactoryBot.create(:stone) }
      let(:stone) { FactoryBot.create(:stone, parent_id: parent_id) }
      let(:child_stone) { FactoryBot.create(:stone, parent_id: stone.id) }
      let(:user) { FactoryBot.create(:user) }
      before do
        User.current = user
        parent_stone
        stone
        child_stone
      end
      context "is nil" do
        let(:parent_id) { nil }
        it { expect(stone).to be_valid }
      end
      context "is present" do
        let(:parent_id) { parent_stone.id }
        context "and parent_id equal self.id" do
          before { stone.parent_id = stone.id }
          it { expect(stone).not_to be_valid }
        end
        context "and parent_id equal child_box.id" do
          before { stone.parent_id = child_stone.id }
          it { expect(stone).not_to be_valid }
        end
        context "and valid id" do
          it { expect(stone).to be_valid }
        end
      end
    end
  end

  describe "global id virtual attributes" do
    let(:stone) { Stone.new }

    describe "#parent_global_id" do
      let(:parent_stone) { FactoryBot.create(:stone) }

      it "returns the parent's global id" do
        stone.parent = parent_stone
        expect(stone.parent_global_id).to eq parent_stone.global_id
      end

      it "sets parent_id from a stone global id" do
        stone.parent_global_id = parent_stone.global_id
        expect(stone.parent_id).to eq parent_stone.id
      end

      it "ignores global ids from another datum type" do
        stone.parent_global_id = FactoryBot.create(:place).global_id
        expect(stone.parent_id).to be_nil
      end
    end

    describe "#place_global_id" do
      let(:place) { FactoryBot.create(:place) }

      it "returns the place global id" do
        stone.place = place
        expect(stone.place_global_id).to eq place.global_id
      end

      it "sets place_id from a place global id" do
        stone.place_global_id = place.global_id
        expect(stone.place_id).to eq place.id
      end

      it "ignores an unknown global id" do
        stone.place_global_id = "missing-global-id"
        expect(stone.place_id).to be_nil
      end
    end

    describe "#box_global_id" do
      let(:box) { FactoryBot.create(:box) }

      it "returns the box global id" do
        stone.box = box
        expect(stone.box_global_id).to eq box.global_id
      end

      it "sets box_id from a box global id" do
        stone.box_global_id = box.global_id
        expect(stone.box_id).to eq box.id
      end

      it "ignores global ids from another datum type" do
        stone.box_global_id = FactoryBot.create(:collection).global_id
        expect(stone.box_id).to be_nil
      end
    end

    describe "#collection_global_id" do
      let(:collection) { FactoryBot.create(:collection) }

      it "returns the collection global id" do
        stone.collection = collection
        expect(stone.collection_global_id).to eq collection.global_id
      end

      it "sets collection_id from a collection global id" do
        stone.collection_global_id = collection.global_id
        expect(stone.collection_id).to eq collection.id
      end

      it "ignores blank input" do
        stone.collection_global_id = ""
        expect(stone.collection_id).to be_nil
      end
    end
  end

end
