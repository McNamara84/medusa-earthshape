# frozen_string_literal: true

# Patch Settingslogic to support YAML aliases in Ruby 3.1+
#
# IMPORTANT: This patch is specifically for settingslogic gem version 2.0.9
# If the gem is updated, this patch should be reviewed and potentially removed
# or updated to match the new gem's implementation.
#
# The settingslogic gem (2.0.9) uses YAML.load without aliases: true,
# which causes Psych::AliasesNotEnabled errors with Ruby 3.1+
#
# This patch uses Module#prepend to override initialize and reload! methods
# with YAML.safe_load for security and compatibility.
#
# Permitted classes: The application.yml contains only basic types
# (strings, integers, booleans, nil, hashes, arrays) which are allowed
# by default in safe_load. Symbol, Date, and Time are added for safety
# in case future configs need them.
#
# Note: This application requires Ruby 3.2.6+ (see Gemfile)
#
# Reference: https://github.com/binarylogic/settingslogic/blob/v2.0.9/lib/settingslogic.rb

# Shared YAML loading options for consistency across the application
# Used by Settingslogic patch and specs that need to load application.yml
module SettingsYamlConfig
  # Options for YAML.safe_load when loading application.yml
  # - permitted_classes: Symbol, Date, Time (basic types that may appear in config)
  # - aliases: true (required for YAML anchors like &defaults / *defaults)
  YAML_LOAD_OPTIONS = {
    permitted_classes: [Symbol, Date, Time],
    aliases: true
  }.freeze

  def self.safe_load_yaml(content)
    YAML.safe_load(content, **YAML_LOAD_OPTIONS)
  end

  def self.safe_load_file(file_path)
    safe_load_yaml(File.read(file_path))
  end
end

if defined?(Settingslogic)
  # Use Module#prepend for cleaner monkey-patching that avoids alias_method conflicts
  module SettingslogicYamlAliasPatch
    def initialize(hash_or_file = self.class.source, section = nil)
      if hash_or_file.is_a?(Hash)
        # Delegate to original for hash input
        super
      else
        # File path - load with aliases enabled using safe_load for security
        file_path = hash_or_file
        if File.exist?(file_path)
          hash = SettingsYamlConfig.safe_load_file(file_path)

          # Apply section/namespace if specified
          hash = hash[section] if section && hash.is_a?(Hash)

          # Initialize the hash-like structure
          self.replace(hash || {})
          @section = section
          create_accessors!
        else
          raise Errno::ENOENT, "No such file or directory - #{file_path}"
        end
      end
    end
  end

  class Settingslogic
    prepend SettingslogicYamlAliasPatch

    class << self
      # Override reload! to reset instance and trigger patched initialize
      def reload!
        @instance = nil
        instance
      end
    end
  end
end
