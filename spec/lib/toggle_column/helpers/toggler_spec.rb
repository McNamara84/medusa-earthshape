require "spec_helper"

describe ToggleColumn::Helpers::Toggler do
  let(:toggle_state) { "expand" }
  let(:params) { ActionController::Parameters.new(toggle_column: toggle_state, page: "2") }
  let(:template) { instance_double(ActionView::Base, params: params) }
  subject(:toggler) { described_class.new(template, class: "btn") }

  describe "#expand?" do
    it "returns true when the toggle param is expand" do
      expect(toggler.expand?).to be(true)
    end
  end

  describe "#fold?" do
    context "when expanded" do
      it "returns false" do
        expect(toggler.fold?).to be(false)
      end
    end

    context "when folded" do
      let(:toggle_state) { "fold" }

      it "returns true" do
        expect(toggler.fold?).to be(true)
      end
    end
  end

  describe "#icon" do
    it "renders the current icon" do
      expect(template).to receive(:content_tag).with(:i, nil, class: "bi bi-chevron-left").and_return("<i></i>")

      expect(toggler.icon).to eq("<i></i>")
    end
  end

  describe "#url_for" do
    it "merges the toggle_column parameter into the current params" do
      expect(template).to receive(:url_for).with({ "toggle_column" => "fold", "page" => "2" }).and_return("/stones?toggle_column=fold&page=2")

      expect(toggler.url_for("fold")).to eq("/stones?toggle_column=fold&page=2")
    end
  end

  describe "#to_s" do
    it "builds a toggle link with the opposite state" do
      allow(template).to receive(:content_tag).with(:i, nil, class: "bi bi-chevron-left").and_return("<i></i>")
      allow(template).to receive(:url_for).with({ "toggle_column" => "fold", "page" => "2" }).and_return("/stones?toggle_column=fold&page=2")
      expect(template).to receive(:link_to).with("<i></i>", "/stones?toggle_column=fold&page=2", { class: "btn" }).and_return("<a></a>")

      expect(toggler.to_s).to eq("<a></a>")
    end
  end

  describe "private helpers" do
    it "uses the left icon and fold target while expanded" do
      expect(toggler.send(:icon_name)).to eq("chevron-left")
      expect(toggler.send(:toggled_param)).to eq("fold")
    end

    it "uses the right icon and expand target while folded" do
      folded = described_class.new(instance_double(ActionView::Base, params: ActionController::Parameters.new(toggle_column: "fold")))

      expect(folded.send(:icon_name)).to eq("chevron-right")
      expect(folded.send(:toggled_param)).to eq("expand")
    end
  end
end