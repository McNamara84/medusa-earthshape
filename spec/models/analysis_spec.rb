require 'spec_helper'
require 'securerandom'

describe Analysis do

  describe "constants" do
    describe "PERMIT_IMPORT_TYPES" do
      it "includes CsvImportable" do
        expect(Analysis.ancestors).to include(CsvImportable)
      end
      it "has access to PERMIT_IMPORT_TYPES via CsvImportable" do
        expect(CsvImportable::PERMIT_IMPORT_TYPES).to include("text/plain", "text/csv", "application/csv", "application/vnd.ms-excel")
      end
    end
  end

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryBot.build(:analysis, name: name) }
      context "is presence" do
        let(:name) { "sample_analysis" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
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

  describe "#chemistry_summary" do
    let(:analysis) { FactoryBot.create(:analysis) }
    let(:chemistries) { [chemistry_1, chemistry_2] }
    let(:chemistry_1) { FactoryBot.build(:chemistry, analysis: analysis, measurement_item: measurement_item_1) }
    let(:chemistry_2) { FactoryBot.build(:chemistry, analysis: analysis, measurement_item: measurement_item_2) }
    let(:measurement_item_1) { FactoryBot.create(:measurement_item) }
    let(:measurement_item_2) { FactoryBot.create(:measurement_item) }
    let(:display_name_1) { "display_name_1" }
    let(:display_name_2) { "display_name_2" }
    before do
      allow(analysis).to receive(:chemistries).and_return(chemistries)
      allow(chemistry_1).to receive(:display_name).and_return(display_name_1)
      allow(chemistry_2).to receive(:display_name).and_return(display_name_2)
    end
    context "method call with no argument" do
      subject { analysis.chemistry_summary }
      context "chemistry.measurement_item is present" do
        it { expect(subject).to eq "display_name_1, display_name_2" }
      end
      context "chemistry.measurement_item is present and display_name is 90 characters" do
        let(:display_name_1) { "a" * 90 }
        let(:display_name_2) { "b" * 90 }
        it { expect(subject).to eq(display_name_1 + ", " + "bbbbb...") }
      end
      context "chemistry.measurement_item is blank" do
        let(:chemistry_1) { FactoryBot.build(:chemistry, analysis: analysis, measurement_item: nil) }
        let(:chemistry_2) { FactoryBot.build(:chemistry, analysis: analysis, measurement_item: nil) }
        it { expect(subject).to eq "" }
      end
    end
    context "method call with 50" do
      subject { analysis.chemistry_summary(50) }
      context "chemistry.measurement_item is present" do
        it { expect(subject).to eq "display_name_1, display_name_2" }
      end
      context "chemistry.measurement_item is present and display_name is 90 characters" do
        let(:display_name_1) { "a" * 90 }
        let(:display_name_2) { "b" * 90 }
        it { expect(subject).to eq("a" * 47 + "...") }
      end
      context "chemistry.measurement_item is blank" do
        let(:chemistry_1) { FactoryBot.build(:chemistry, analysis: analysis, measurement_item: nil) }
        let(:chemistry_2) { FactoryBot.build(:chemistry, analysis: analysis, measurement_item: nil) }
        it { expect(subject).to eq "" }
      end
    end
  end

  describe "stone_global_id" do
    let(:stone){FactoryBot.create(:stone)}
    let(:analysis){FactoryBot.create(:analysis)}
    context "get" do
      context "stone_id is nil" do
        before{analysis.stone_id = nil}
        it {expect(analysis.stone_global_id).to be_blank}
      end
      context "stone_id is ng" do
        before{analysis.stone_id = 0}
        it {expect(analysis.stone_global_id).to be_blank}
      end
      context "stone_id is ok" do
        before{analysis.stone_id = stone.id}
        it {expect(analysis.stone_global_id).to eq stone.global_id}
      end
    end
    context "set" do
      context "stone_global_id is nil" do
        before{analysis.stone_global_id = nil}
        it {expect(analysis.stone).to be_blank}
      end
      context "stone_global_id is ng" do
        before{analysis.stone_global_id = "xxxxxxxxxxxxxxxxx"}
        it {expect(analysis.stone).to be_blank}
      end
      context "stone_global_id is ok" do
        before{analysis.stone_global_id = stone.global_id}
        it {expect(analysis.stone).to eq stone}
      end
    end
  end

  describe "#device_name=" do
    before { analysis.device_name = name }
    let(:analysis) { FactoryBot.build(:analysis, device: nil) }
    context "name is exist device name" do
      let(:name) { device.name }
      let(:device) { FactoryBot.create(:device) }
      it { expect(analysis.device_id).to eq device.id }
    end
    context "name is not device name" do
      let(:name) { "nonexistent_device_name_#{Time.now.to_i}" }
      it { expect(analysis.device_id).to be_nil }
    end
  end

  describe "#technique_name=" do
    before { analysis.technique_name = name }
    let(:analysis) { FactoryBot.build(:analysis, technique: nil) }
    context "name is exist technique name" do
      let(:name) { technique.name }
      let(:technique) { FactoryBot.create(:technique) }
      it { expect(analysis.technique_id).to eq technique.id }
    end
    context "name is not technique name" do
      let(:name) { "hoge" }
      it { expect(analysis.technique_id).to be_nil }
    end
  end

  describe ".import_csv" do
    subject { Analysis.import_csv(file) }
    context "file is nil" do
      let(:file) { nil }
      it { expect(subject).to be_nil }
    end
    context "file is present" do
      let(:file) { double(:file) }
      let(:objects) { [analysis] }
      before do
        allow(file).to receive(:content_type).and_return(content_type)
        allow(Analysis).to receive(:build_objects_from_csv).with(file).and_return(objects)
      end
      context "content_type is 'csv'" do
        let(:content_type) { 'text/csv' }
        context "objects is all valid" do
          let(:analysis) { FactoryBot.build(:analysis) }
          it { expect(subject).to be_present }
        end
        context "object is invalid" do
          let(:analysis) { FactoryBot.build(:analysis, name: nil) }
          it { expect(subject).to eq false }
        end
      end
      context "content_type is not 'csv'" do
        let(:content_type) { 'image/png' }
        context "objects is all valid" do
          let(:analysis) { FactoryBot.build(:analysis) }
          it { expect(subject).to be_nil }
        end
        context "object is invalid" do
          let(:analysis) { FactoryBot.build(:analysis, name: nil) }
          it { expect(subject).to be_nil }
        end
      end
    end
  end

  describe ".build_objects_from_csv" do
    subject { Analysis.build_objects_from_csv(file) }
    let(:file) { double(:file) }
    let(:csv_read) { [["header ", nil], [row_1], [row_2]] }
    let(:row_1) { "row_1" }
    let(:row_2) { "row_2" }
    let(:object_1) { double(:object_1) }
    let(:object_2) { double(:object_2) }
    before do
      allow(file).to receive(:read)
      allow(CSV).to receive(:parse).and_return(csv_read)
      allow(Analysis).to receive(:set_object).with(["header_"], [row_1]).and_return(object_1)
      allow(Analysis).to receive(:set_object).with(["header_"], [row_2]).and_return(object_2)
    end
    it { expect(subject).to eq [object_1, object_2] }
  end

  describe ".set_object" do
    let(:existing_analysis) { FactoryBot.create(:analysis, name: "original", operator: "before") }
    let(:methods) { ["id", "name", "operator"] }

    it "updates an existing record when id is present" do
      object = Analysis.set_object(methods, [existing_analysis.id, " updated ", " operator "])

      expect(object).to eq(existing_analysis)
      expect(object.name).to eq("updated")
      expect(object.operator).to eq("operator")
    end

    it "builds a new record when no id column is provided" do
      object = Analysis.set_object(["name", "operator"], [" new analysis ", " new operator "])

      expect(object).to be_a_new(Analysis)
      expect(object.name).to eq("new analysis")
      expect(object.operator).to eq("new operator")
    end
  end

  describe "dynamic chemistry accessors" do
    let(:analysis) { FactoryBot.create(:analysis) }
    let(:suffix) { SecureRandom.hex(4) }
    let(:nickname) { "fe_#{suffix}" }
    let(:unit_name) { "g#{suffix.first(4)}" }
    let(:unit) { FactoryBot.create(:unit, name: unit_name, html: unit_name, text: unit_name, conversion: 1) }
    let(:measurement_item) { FactoryBot.create(:measurement_item, nickname: nickname, unit: measurement_item_unit) }
    let(:measurement_item_unit) { unit }

    describe "#method_missing for setters" do
      it "creates a chemistry using the explicit unit in the method name" do
        measurement_item
        setter_name = "#{nickname}_in_#{unit_name}="

        expect {
          analysis.public_send(setter_name, " 12.5 ")
        }.to change { analysis.chemistries.length }.by(1)

        chemistry = analysis.chemistries.last
        expect(chemistry.measurement_item.nickname).to eq(nickname)
        expect(chemistry.unit.name).to eq(unit_name)
        expect(chemistry.value).to eq(12.5)
      end

      it "uses the measurement item's default unit when no unit suffix is provided" do
        measurement_item
        setter_name = "#{nickname}="

        analysis.public_send(setter_name, "7.5")

        chemistry = analysis.chemistries.last
        expect(chemistry.measurement_item.nickname).to eq(nickname)
        expect(chemistry.unit.name).to eq(unit_name)
        expect(chemistry.value).to eq(7.5)
      end

      it "updates uncertainty through the _error accessor" do
        chemistry = analysis.chemistries.create!(measurement_item: measurement_item, unit: unit, value: 1.5)
        setter_name = "#{nickname}_error="

        analysis.public_send(setter_name, " 0.25 ")

        expect(chemistry.uncertainty).to eq(0.25)
      end
    end

    describe "#method_missing for getters" do
      let(:measurement_item_unit) { nil }

      it "returns the chemistry value when no unit conversion is needed" do
        analysis.chemistries.create!(measurement_item: measurement_item, unit: nil, value: 3.25)

        expect(analysis.public_send(nickname)).to eq(3.25)
      end

      it "returns nil when no chemistry exists for the nickname" do
        measurement_item

        expect(analysis.public_send(nickname)).to be_nil
      end

      it "raises NoMethodError for an unknown nickname" do
        expect { analysis.unknown_measurement = 1 }.to raise_error(NoMethodError)
      end
    end

    describe "#associate_chemistry_by_item_nickname" do
      it "returns the first matching chemistry" do
        matching = analysis.chemistries.create!(measurement_item: measurement_item, unit: unit, value: 8)
        analysis.chemistries.create!(measurement_item: FactoryBot.create(:measurement_item, nickname: "mg"), value: 1)

        expect(analysis.associate_chemistry_by_item_nickname(nickname)).to eq(matching)
      end

      it "returns a matching unsaved chemistry from memory without querying persisted chemistries" do
        analysis.chemistries.load_target
        matching = analysis.chemistries.build(measurement_item: measurement_item, unit: unit, value: 8)

        expect(analysis.chemistries).not_to receive(:joins)

        expect(analysis.associate_chemistry_by_item_nickname(nickname)).to eq(matching)
      end

      it "queries persisted chemistries without loading the full association" do
        matching = analysis.chemistries.create!(measurement_item: measurement_item, unit: unit, value: 8)
        analysis.reload

        expect(analysis.association(:chemistries)).not_to be_loaded
        expect(analysis.associate_chemistry_by_item_nickname(nickname)).to eq(matching)
        expect(analysis.association(:chemistries)).not_to be_loaded
      end
    end
  end

  describe "#to_castemls" do
    subject { Analysis.to_castemls(objs) }
    let(:spot){FactoryBot.create(:spot)}
    let(:attachment_file){FactoryBot.create(:attachment_file)}
    let(:chemistry){FactoryBot.create(:chemistry)}
    let(:obj) { FactoryBot.create(:analysis) }
    let(:obj2) { FactoryBot.create(:analysis) }
    let(:objs){ [obj,obj2]}
    before do
      attachment_file.spots << spot
      obj.attachment_files << attachment_file
      obj.chemistries << chemistry
    end
    it {expect(subject).to be_present}
  end

  describe "#to_pml", :current => true do
    let(:box){ FactoryBot.create(:box)}
    let(:stone){ FactoryBot.create(:stone, box_id: box.id)}
    let(:spot){FactoryBot.create(:spot)}
    let(:attachment_file){FactoryBot.create(:attachment_file)}
    let(:chemistry){FactoryBot.create(:chemistry)}
    let(:obj) { FactoryBot.create(:analysis) }
    let(:obj2) { FactoryBot.create(:analysis) }
    let(:obj3) do
      analysis = FactoryBot.create(:analysis)
      analysis.stones << stone
      analysis
    end
    let(:objs){ [obj,obj2, stone]}
    let(:objs2){ [obj,obj2,box]}
    before do
      attachment_file.spots << spot
      obj.attachment_files << attachment_file
      obj.chemistries << chemistry
      obj3
    end
    it { expect(obj.to_pml).to be_present }
    it { expect(objs.to_pml).to be_eql([obj, obj2, obj3].to_pml) }
    it { expect(objs2.to_pml).to be_eql([obj, obj2, obj3].to_pml) }
  end

  describe ".get_spot" do
    subject { obj.get_spot }
    let(:user){FactoryBot.create(:user)}
    let(:obj) {FactoryBot.create(:analysis) }
    let(:spot1){FactoryBot.create(:spot,target_uid: global_id)}
    let(:spot2){FactoryBot.create(:spot,target_uid: global_id)}
    before{User.current = user}
    context "no spots" do
      let(:global_id){"xxx"}
      before do
        obj
        spot1
      end
      it{expect(subject).to be_nil}
    end
    context "1 spot exists" do
      let(:global_id){obj.global_id}
      before do
        obj
        spot1
      end
      it{expect(subject).to eq spot1}
    end
    context "2 spot exists" do
      let(:global_id){obj.global_id}
      before do
        obj
        spot1
        spot2
      end
      it{expect(subject).to eq spot1}
    end
  end

end
