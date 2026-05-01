require "spec_helper"

describe Staging do
  def csv_row(overrides = {})
    row = Array.new(54, "")
    overrides.each { |index, value| row[index] = value }
    row.join(",")
  end

  describe "#name" do
    it "combines collection and sample names" do
      staging = described_class.new(collection_name: "Campaign A", sample_name: "Sample 1")

      expect(staging.name).to eq("Campaign A-Sample 1")
    end
  end

  describe "#create_places" do
    it "builds a place from the staged place attributes" do
      staging = described_class.new(
        place_name: "Outcrop 1",
        place_longitude: "13.4",
        place_latitude: "52.5",
        place_elevation: 120.0,
        place_topographic_position: 2,
        place_slopedescription: "gentle",
        place_aspect: "south",
        place_vegetation: 3,
        place_landuse: 4,
        place_description: "Basalt ridge",
        place_lightsituation: "sunny"
      )

      place = staging.create_places

      expect(place).to be_a(Place)
      expect(place.name).to eq("Outcrop 1")
      expect(place.longitude).to eq(13.4)
      expect(place.latitude).to eq(52.5)
      expect(place.elevation).to eq(120.0)
      expect(place.topographic_position_id).to eq(2)
      expect(place.slope_description).to eq("gentle")
      expect(place.aspect).to eq("south")
      expect(place.vegetation_id).to eq(3)
      expect(place.landuse_id).to eq(4)
      expect(place.description).to eq("Basalt ridge")
      expect(place.lightsituation).to eq("sunny")
    end
  end

  describe "#create_samples" do
    it "builds a stone from the staged sample attributes" do
      staging = described_class.new(
        sample_name: "Sample 1",
        sample_igsn: "GFABC1234",
        sample_labname: "LAB-1",
        sample_date: Date.new(2024, 1, 2),
        sample_depth: 4.5,
        sample_comment: "Fresh sample",
        sample_classification: 2,
        sample_container: 7,
        sample_quantityinitial: 10.0,
        sample_unit: "g",
        sample_quantity: 8.5
      )

      stone = staging.create_samples

      expect(stone).to be_a(Stone)
      expect(stone.name).to eq("Sample 1")
      expect(stone.igsn).to eq("GFABC1234")
      expect(stone.labname).to eq("LAB-1")
      expect(stone.date).to eq(Date.new(2024, 1, 2))
      expect(stone.sampledepth).to eq(4.5)
      expect(stone.description).to eq("Fresh sample")
      expect(stone.classification_id).to eq(2)
      expect(stone.stonecontainer_type_id).to eq(7)
      expect(stone.quantity_initial).to eq(10.0)
      expect(stone.quantity_unit).to eq("g")
      expect(stone.quantity).to eq(8.5)
    end
  end

  describe ".import_csv" do
    let(:filename) { "staging.csv" }

    it "raises when no file is provided" do
      expect { described_class.import_csv(nil) }.to raise_error(StandardError, /failed to retrieve the file/)
    end

    it "raises when the content type is not permitted" do
      file = instance_double("UploadedFile", content_type: "application/json", original_filename: filename)

      expect { described_class.import_csv(file) }.to raise_error(StandardError, /not in the list of known file types/)
    end

    it "raises when the CSV header is invalid" do
      file = instance_double(
        "UploadedFile",
        content_type: "text/csv",
        original_filename: filename,
        read: "Wrong Header\nStill Wrong\n"
      )

      expect { described_class.import_csv(file) }.to raise_error(StandardError, /CSV file is invalid or is empty/)
    end

    it "imports rows after a valid campaign header" do
      csv_content = [
        csv_row(0 => "Campaign"),
        csv_row(0 => "Campaign A", 1 => "Project A", 8 => "Place A", 25 => "Sample A")
      ].join("\n")
      file = instance_double(
        "UploadedFile",
        content_type: "text/csv",
        original_filename: filename,
        read: csv_content
      )

      expect_any_instance_of(described_class).to receive(:save!).once.and_return(true)

      expect(described_class.import_csv(file)).to be(true)
    end
  end
end