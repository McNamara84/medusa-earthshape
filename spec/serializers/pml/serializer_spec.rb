require "spec_helper"
require "rexml/document"

RSpec.describe Pml::Serializer do
  def parse_xml(xml)
    REXML::Document.new(xml)
  end

  def acquisitions_element(xml)
    doc = parse_xml(xml)
    REXML::XPath.first(doc, "/acquisitions")
  end

  def acquisitions_children_names(xml)
    acquisitions = acquisitions_element(xml)
    return [] unless acquisitions

    acquisitions.elements.to_a.map(&:name)
  end

  describe ".call" do
    it "renders an XML document with <acquisitions> root" do
      xml = described_class.call([])
      expect(xml).to start_with("<?xml")
      expect(acquisitions_element(xml)).not_to be_nil
      expect(acquisitions_children_names(xml)).to eq([])
    end

    it "handles nil by rendering an empty <acquisitions> list" do
      xml = described_class.call(nil)
      expect(acquisitions_element(xml)).not_to be_nil
      expect(acquisitions_children_names(xml)).to eq([])
    end

    it "serializes a single Analysis as one <acquisition>" do
      analysis = FactoryBot.create(:analysis, description: "説明１")
      xml = described_class.call(analysis)

      acquisitions = acquisitions_element(xml)
      expect(acquisitions).not_to be_nil
      expect(acquisitions_children_names(xml)).to eq(["acquisition"])

      acquisition = acquisitions.elements[1]
      expect(acquisition.elements["global_id"]&.text).to eq(analysis.global_id)
      expect(acquisition.elements["description"]&.text).to eq("説明１")
    end

    it "serializes arrays by iterating over each item" do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_2 = FactoryBot.create(:analysis)

      xml = described_class.call([analysis_1, analysis_2])
      expect(acquisitions_children_names(xml)).to eq(["acquisition", "acquisition"])
    end

    it "serializes RecordProperty by delegating to datum" do
      analysis = FactoryBot.create(:analysis)
      record_property = analysis.record_property

      xml = described_class.call(record_property)
      acquisition = REXML::XPath.first(parse_xml(xml), "/acquisitions/acquisition")
      expect(acquisition.elements["global_id"]&.text).to eq(analysis.global_id)
    end

    it "serializes objects responding to #analysis" do
      analysis = FactoryBot.create(:analysis)
      wrapper = Struct.new(:analysis).new(analysis)

      xml = described_class.call(wrapper)
      acquisition = REXML::XPath.first(parse_xml(xml), "/acquisitions/acquisition")
      expect(acquisition.elements["global_id"]&.text).to eq(analysis.global_id)
    end

    it "serializes objects responding to #analyses" do
      analysis_1 = FactoryBot.create(:analysis)
      analysis_2 = FactoryBot.create(:analysis)

      wrapper_class = Class.new do
        def initialize(analyses)
          @analyses = analyses
        end

        def analyses
          @analyses
        end
      end

      xml = described_class.call(wrapper_class.new([analysis_1, analysis_2]))
      expect(acquisitions_children_names(xml)).to eq(["acquisition", "acquisition"])
    end

    it "does not treat String as a collection" do
      xml = described_class.call("not-a-collection")
      expect(acquisitions_element(xml)).not_to be_nil
      expect(acquisitions_children_names(xml)).to eq([])
    end

    it "does not treat Hash as a collection" do
      xml = described_class.call({"a" => 1})
      expect(acquisitions_element(xml)).not_to be_nil
      expect(acquisitions_children_names(xml)).to eq([])
    end
  end
end
