require "spec_helper"

class OutputCsvSpec < ActiveRecord::Base
  include OutputCsv
end

class OutputCsvFallbackSpec < ActiveRecord::Base
  self.table_name = "output_csv_fallback_specs"
  include OutputCsv
end

class OutputCsvSpecMigration < ActiveRecord::Migration[4.2]
  def self.up
    create_table :output_csv_specs do |t|
      t.string :name
      t.string :global_id
    end

    create_table :output_csv_fallback_specs do |t|
      t.string :name
    end
  end
  def self.down
    drop_table :output_csv_specs
    drop_table :output_csv_fallback_specs
  end
end

describe OutputCsv do
  let(:klass) { OutputCsvSpec }
  let(:migration) { OutputCsvSpecMigration }

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }

  describe "constants" do
    describe "LABEL_HEADER" do
      subject { klass::LABEL_HEADER }
      it { expect(subject).to eq ["Id","Name"] }
    end
  end

  describe "build_label" do
    subject { obj.build_label }
    let(:obj) { klass.create(name: "foo", global_id: "1234") }
    # Updated to match new implementation that outputs all attributes
    # instead of just LABEL_HEADER fields
    it "includes all attributes in CSV output" do
      expect(subject).to include("global_id")
      expect(subject).to include("id")
      expect(subject).to include("name")
      expect(subject).to include("foo")
      expect(subject).to include("1234")
    end

    it "falls back to the record property global id when the model has no global_id attribute" do
      obj = OutputCsvFallbackSpec.create(name: "fallback")
      logger = instance_double(Logger, info: true)
      record_property = instance_double(RecordProperty, global_id: "fallback-gid")
      call_count = 0

      allow(obj).to receive(:logger).and_return(logger)
      allow(obj).to receive(:attributes) do
        call_count += 1
        call_count == 1 ? { "name" => "fallback", "unused" => "value" } : { "name" => "fallback" }
      end
      relation = double(:relation)
      allow(RecordProperty).to receive(:where).with(datum_type: "OutputCsvFallbackSpec").and_return(relation)
      allow(relation).to receive(:where).with(datum_id: obj.id).and_return(relation)
      allow(relation).to receive(:take).and_return(record_property)

      csv = obj.build_label

      expect(logger).to have_received(:info).with('"OutputCsvFallbackSpec"')
      expect(csv).to include("fallback-gid")
      expect(csv).to include("fallback")
    end
  end

  describe "build_bundle_label" do
    subject { klass::build_bundle_label(resources) }
    let(:resources) { [obj_1, obj_2] }
    let(:obj_1) { klass.create(name: "foo", global_id: "123") }
    let(:obj_2) { klass.create(name: "bar", global_id: "456") }
    it { expect(subject).to eq "Id,Name\n123,foo\n456,bar\n" }
  end

end
