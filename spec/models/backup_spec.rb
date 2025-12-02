# frozen_string_literal: true

require 'spec_helper'

describe Backup do
  # The Backup model provides configuration access for backup operations
  # Used by lib/tasks/backup.rake for remote backup functionality
  
  describe "Configuration accessors" do
    describe ".host" do
      it "returns the backup server host from settings" do
        expect(Backup.host).to eq(Settings.backup_server.host)
      end
      
      it "returns a non-empty string" do
        expect(Backup.host).to be_present
      end
    end
    
    describe ".username" do
      it "returns the backup server username from settings" do
        expect(Backup.username).to eq(Settings.backup_server.username)
      end
      
      it "returns a non-empty string" do
        expect(Backup.username).to be_present
      end
    end
    
    describe ".dir_path" do
      it "returns the backup server directory paths from settings" do
        expect(Backup.dir_path).to eq(Settings.backup_server.dir_path)
      end
      
      it "contains files and db paths" do
        expect(Backup.dir_path.files).to be_present
        expect(Backup.dir_path.db).to be_present
      end
    end
    
    describe ".ssh_host" do
      it "returns username@host format" do
        expected = "#{Backup.username}@#{Backup.host}"
        expect(Backup.ssh_host).to eq(expected)
      end
      
      it "combines username and host correctly" do
        # Test the actual format matches expected pattern
        expect(Backup.ssh_host).to match(/\A.+@.+\z/)
      end
    end
  end
  
  describe "Integration with Settings" do
    it "delegates to Settings.backup_server" do
      expect(Backup.host).to eq(Settings.backup_server.host)
      expect(Backup.username).to eq(Settings.backup_server.username)
      expect(Backup.dir_path).to eq(Settings.backup_server.dir_path)
    end
  end
end
