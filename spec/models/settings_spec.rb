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

  # NOTE: The following tests are skipped because they have fundamental design issues:
  # 1. They modify the global application.yml file which affects all other tests
  # 2. They modify "defaults" namespace instead of "test" namespace
  # 3. Settings.reload! can cause race conditions in parallel test execution
  # 4. The after blocks may not restore the original state properly
  #
  # These tests should be rewritten to:
  # - Use RSpec mocking/stubbing for Settings class methods
  # - Or use a test-specific YAML file that doesn't affect production config
  # - Or be removed entirely as they test Settingslogic gem behavior, not app code
  #
  # For now, the basic inheritance/source/namespace tests above provide
  # sufficient coverage for the Settings class configuration.
  #
  # HISTORICAL NOTE: All 4 barcode tests below were already skipped (`xit`) since
  # commit 336684f (2023) - they were NOT newly disabled during the Rails 7.0 upgrade.
  #
  # TODO: Track in GitHub issue to properly rewrite or remove these flaky tests.
  #       See: https://github.com/McNamara84/medusa-earthshape/issues (create issue)

  describe ".barcode_type" do
    let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
    # Use shared YAML config from SettingsYamlConfig for consistency
    let(:data) { SettingsYamlConfig.safe_load_file(file_yaml) }
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
      xit {expect(Settings.barcode_type).to eq "3D"}
    end
    context "yml nil " do
      before do
          data["defaults"]["barcode"]["type"] = nil
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      xit {expect(Settings.barcode_type).to eq '2D'}
    end
  end

  describe ".barcode_prefix" do
    let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
    # Use shared YAML config from SettingsYamlConfig for consistency
    let(:data) { SettingsYamlConfig.safe_load_file(file_yaml) }
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
      xit {expect(Settings.barcode_prefix).to eq "aaa"}
    end
    context "yml nil " do
      before do
          data["defaults"]["barcode"]["prefix"] = nil
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      xit {expect(Settings.barcode_prefix).to eq ''}
    end
  end
end
