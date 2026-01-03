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
    it { expect(stone1.to_pml).to eql(Pml::Serializer.call([analysis_2, analysis_1]))}
    it { expect(stone2.analyses.count).to eq 2}
    it { expect(stone2.to_pml).to eql(Pml::Serializer.call([analysis_4, analysis_3]))}
    it { expect(Pml::Serializer.call(stones)).to eql(Pml::Serializer.call([analysis_2, analysis_1])) }
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

end
