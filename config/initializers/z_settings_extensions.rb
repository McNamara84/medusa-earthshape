# frozen_string_literal: true

# Custom Settings extensions for Medusa
# These helper methods provide convenient access to barcode configuration
# with sensible defaults when values are not set.
#
# This file is named with 'z_' prefix to ensure it loads after the config gem
# has created the Settings object via its Railtie.

module SettingsExtensions
  # Returns the configured barcode type, defaulting to '2D' if not set
  def barcode_type
    barcode&.type || '2D'
  end

  # Returns the configured barcode prefix, defaulting to empty string if not set
  def barcode_prefix
    barcode&.prefix || ''
  end
end

# Extend the Settings object with our custom methods
Settings.extend(SettingsExtensions)
