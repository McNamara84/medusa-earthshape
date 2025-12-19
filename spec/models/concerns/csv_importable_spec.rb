require 'spec_helper'

describe CsvImportable do
  describe "PERMIT_IMPORT_TYPES" do
    subject { CsvImportable::PERMIT_IMPORT_TYPES }

    it { is_expected.to include("text/plain") }
    it { is_expected.to include("text/csv") }
    it { is_expected.to include("text/x-csv") }
    it { is_expected.to include("text/comma-separated-values") }
    it { is_expected.to include("application/csv") }
    it { is_expected.to include("application/x-csv") }
    it { is_expected.to include("application/vnd.ms-excel") }
    it { is_expected.to include("application/octet-stream") }
    it { is_expected.to be_frozen }
  end

  describe ".csv_file_valid?" do
    # Create a test class that includes the concern
    let(:test_class) do
      Class.new do
        include CsvImportable
      end
    end

    context "when file is nil" do
      it "returns false" do
        expect(test_class.csv_file_valid?(nil)).to be false
      end
    end

    context "when file has valid content type" do
      let(:file) { double("file", content_type: "text/csv") }

      it "returns true" do
        expect(test_class.csv_file_valid?(file)).to be true
      end
    end

    context "when file has application/octet-stream content type" do
      let(:file) { double("file", content_type: "application/octet-stream") }

      it "returns true" do
        expect(test_class.csv_file_valid?(file)).to be true
      end
    end

    context "when file has invalid content type" do
      let(:file) { double("file", content_type: "image/png") }

      it "returns false" do
        expect(test_class.csv_file_valid?(file)).to be false
      end
    end
  end
end
