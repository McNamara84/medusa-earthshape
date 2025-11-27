# frozen_string_literal: true

# Patch Settingslogic to support YAML aliases in Ruby 3.1+
# The settingslogic gem (2.0.9) uses YAML.load without aliases: true,
# which causes Psych::AliasesNotEnabled errors with Ruby 3.1+
#
# This patch overrides both initialize and reload! methods to use
# YAML.safe_load with aliases: true for security and compatibility.
#
# Permitted classes: The application.yml contains only basic types
# (strings, integers, booleans, nil, hashes, arrays) which are allowed
# by default in safe_load. Symbol, Date, and Time are added for safety
# in case future configs need them.
#
# Note: This application requires Ruby 3.2.6+ (see Gemfile)

if defined?(Settingslogic)
  class Settingslogic
    class << self
      # Override reload! to use our patched YAML loading
      def reload!
        @instance = nil
        instance
      end
    end

    # Store original method
    alias_method :original_initialize, :initialize

    def initialize(hash_or_file = self.class.source, section = nil)
      if hash_or_file.is_a?(Hash)
        # Original behavior for hash input
        original_initialize(hash_or_file, section)
      else
        # File path - load with aliases enabled using safe_load for security
        file_path = hash_or_file
        if File.exist?(file_path)
          yaml_content = File.read(file_path)
          hash = YAML.safe_load(
            yaml_content,
            permitted_classes: [Symbol, Date, Time],
            aliases: true
          )

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
end
