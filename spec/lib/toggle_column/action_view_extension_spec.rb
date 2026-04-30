require "spec_helper"

describe ToggleColumn::ActionViewExtension do
  let(:template_class) do
    Class.new do
      include ToggleColumn::ActionViewExtension

      def content_tag(name, content_or_options_with_block = nil, options = nil, &block)
        if block && content_or_options_with_block.is_a?(Hash) && options.nil?
          options = content_or_options_with_block
        end
        content = block ? block.call : content_or_options_with_block
        { name: name, content: content, options: options }
      end
    end
  end
  let(:template) { template_class.new }
  let(:toggler) { instance_double(ToggleColumn::Helpers::Toggler, expand?: expand, to_s: "toggle-link") }
  let(:expand) { true }

  before do
    allow(ToggleColumn::Helpers::Toggler).to receive(:new).and_return(toggler)
  end

  describe "#toggle_column_link" do
    it "delegates link rendering to the toggler" do
      expect(ToggleColumn::Helpers::Toggler).to receive(:new).with(template, { class: "btn" })

      expect(template.toggle_column_link(class: "btn")).to eq("toggle-link")
    end
  end

  describe "#th_if_expand" do
    it "renders a table header when expanded" do
      expect(template.th_if_expand("Name", class: "wide")).to eq(name: :th, content: "Name", options: { class: "wide" })
    end
  end

  describe "#td_if_expand" do
    it "renders a table cell from a block when expanded" do
      expect(template.td_if_expand(class: "value") { "Stone" }).to eq(name: :td, content: "Stone", options: { class: "value" })
    end
  end

  describe "#content_tag_if_expand" do
    let(:expand) { false }

    it "returns nil when the toggler is folded" do
      expect(template.content_tag_if_expand(:td, "Stone", class: "value")).to be_nil
    end
  end
end