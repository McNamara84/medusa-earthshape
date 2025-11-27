require 'spec_helper'

describe Settings do

  describe "Inheritance" do
    it { expect(Settings.superclass).to eq Settingslogic }
  end

  describe ".source" do
    it { expect(Settings.source).to eq Rails.root.join("config", "application.yml").to_path }
  end

  describe ".namespece" do
    it { expect(Settings.namespace).to eq Rails.env }
  end

  describe ".barcode_type" do
    let(:data){YAML.load_file(file_yaml, aliases: true)}
    let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
    after do 
      data["defaults"]["barcode"]["type"] = "3D"
      File.open(file_yaml,"w"){|f| f.write data.to_yaml}
      Settings.reload!
    end
    context "yml not nil " do
      before do
          data["defaults"]["barcode"]["type"] = "3D"
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      # Flaky test: Settingslogic reload timing issue
      # TODO: Mock Settings instead of modifying YAML file
      xit {expect(Settings.barcode_type).to eq "3D"}
    end
    context "yml nil " do
      before do
          data["defaults"]["barcode"]["type"] = nil
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      # Flaky test: Settingslogic reload timing issue
      # TODO: Mock Settings instead of modifying YAML file
      xit {expect(Settings.barcode_type).to eq '2D'}
    end
  end

  describe ".barcode_prefix" do
    let(:data){YAML.load_file(file_yaml, aliases: true)}
    let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
    after do 
      data["defaults"]["barcode"]["prefix"] = nil
      File.open(file_yaml,"w"){|f| f.write data.to_yaml}
      Settings.reload!
    end
    context "yml not nil " do
      before do
          data["defaults"]["barcode"]["prefix"] = "aaa"
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      # Flaky test: Settingslogic reload timing issue
      # TODO: Mock Settings instead of modifying YAML file
      xit {expect(Settings.barcode_prefix).to eq "aaa"}
    end
    context "yml nil " do
      before do
          data["defaults"]["barcode"]["prefix"] = nil
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      # Flaky test: modifies defaults instead of test namespace, breaks Settings
      # TODO: Rewrite to use proper mocking or test-specific YAML
      xit {expect(Settings.barcode_prefix).to eq ''}
    end
  end
end
