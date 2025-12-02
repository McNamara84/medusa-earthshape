require 'spec_helper'

describe Settings do

  # The Settings object is now created by the 'config' gem (rubyconfig/config)
  # instead of Settingslogic. The config gem uses a different API.
  
  describe "Configuration" do
    it "uses Config::Options as the Settings class" do
      expect(Settings).to be_a(Config::Options)
    end
    
    it "has site_name setting" do
      expect(Settings.site_name).to be_present
    end
    
    it "has admin settings" do
      expect(Settings.admin).to be_present
      expect(Settings.admin.email).to be_present
    end
    
    it "has barcode settings" do
      expect(Settings.barcode).to be_present
    end
    
    it "has backup settings" do
      expect(Settings.backup).to be_present
      expect(Settings.backup.files.dir_path).to be_present
      expect(Settings.backup.db.dir_path).to be_present
    end
    
    it "has backup_server settings for remote backup" do
      expect(Settings.backup_server).to be_present
      expect(Settings.backup_server.host).to be_present
      expect(Settings.backup_server.username).to be_present
    end
  end
  
  # Tests for custom extension methods defined in config/initializers/z_settings_extensions.rb
  describe "Extension methods" do
    describe ".barcode_type" do
      it "returns '2D' from the configured settings" do
        # Verify the actual configured value is returned correctly
        expect(Settings.barcode_type).to eq('2D')
      end
      
      it "returns '2D' as default when barcode.type is nil" do
        allow(Settings).to receive(:barcode).and_return(
          Config::Options.new(type: nil, prefix: nil)
        )
        expect(Settings.barcode_type).to eq('2D')
      end
    end
    
    describe ".barcode_prefix" do
      it "responds to barcode_prefix method" do
        expect(Settings).to respond_to(:barcode_prefix)
      end
      
      it "returns empty string as default when barcode.prefix is nil" do
        allow(Settings).to receive(:barcode).and_return(
          Config::Options.new(type: '2D', prefix: nil)
        )
        expect(Settings.barcode_prefix).to eq('')
      end
    end
  end
end
