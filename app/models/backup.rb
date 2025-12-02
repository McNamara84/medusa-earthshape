# frozen_string_literal: true

# Backup configuration accessor
# Uses the backup_server settings from config/settings.yml
# Provides class methods for accessing backup server configuration
class Backup
  class << self
    delegate :host, :username, :dir_path, to: :backup_settings

    def ssh_host
      "#{username}@#{host}"
    end

    private

    def backup_settings
      Settings.backup_server
    end
  end
end
