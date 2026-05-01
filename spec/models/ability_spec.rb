require "spec_helper"

describe Ability do
  subject(:ability) { described_class.new(user) }

  let(:user) { instance_double(User, admin?: administrator) }
  let(:administrator) { false }

  describe "admin user" do
    let(:administrator) { true }

    it "can manage permission-backed models" do
      expect(ability.can?(:manage, Stone.new(name: "Spec Stone"))).to be true
      expect(ability.can?(:manage, AttachmentFile.new)).to be true
    end
  end

  describe "permission models" do
    let(:stone) { Stone.new(name: "Spec Stone") }

    before do
      allow(stone).to receive(:readable?).with(user).and_return(readable)
      allow(stone).to receive(:writable?).with(user).and_return(writable)
    end

    context "when the record is readable but not writable" do
      let(:readable) { true }
      let(:writable) { false }

      it "allows read-only actions" do
        expect(ability.can?(:read, stone)).to be true
        expect(ability.can?(:family, stone)).to be true
        expect(ability.can?(:manage, stone)).to be false
      end
    end

    context "when the record is writable" do
      let(:readable) { false }
      let(:writable) { true }

      it "allows manage" do
        expect(ability.can?(:manage, stone)).to be true
      end
    end

    context "when the record is neither readable nor writable" do
      let(:readable) { false }
      let(:writable) { false }

      it "denies access" do
        expect(ability.can?(:read, stone)).to be false
        expect(ability.can?(:download_label, stone)).to be false
        expect(ability.can?(:manage, stone)).to be false
      end
    end
  end

  describe "decorated models" do
    let(:stone) { Stone.new(name: "Decorated Stone").decorate }

    before do
      allow(stone.object).to receive(:readable?).with(user).and_return(true)
      allow(stone.object).to receive(:writable?).with(user).and_return(false)
    end

    it "unwraps decorators for permission checks" do
      expect(ability.can?(:read, stone)).to be true
      expect(ability.can?(:manage, stone)).to be false
    end
  end

  describe "preparations" do
    let(:preparation) { Preparation.new }
    let(:decorated_preparation) { preparation.decorate }

    before do
      allow(preparation).to receive(:readable?).with(user).and_return(false)
      allow(preparation).to receive(:writable?).with(user).and_return(false)
    end

    it "always allows direct preparation access" do
      expect(ability.can?(:read, preparation)).to be true
      expect(ability.can?(:manage, preparation)).to be true
    end

    it "always allows decorated preparation access" do
      expect(ability.can?(:read, decorated_preparation)).to be true
      expect(ability.can?(:manage, decorated_preparation)).to be true
    end
  end
end