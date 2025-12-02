# frozen_string_literal: true

# Custom Settings extensions for Medusa
# These methods provide backward compatibility with the old settingslogic interface
#
# This file is named with 'z_' prefix to ensure it loads after the config gem
# has created the Settings object in config/initializers/config.rb

module SettingsExtensions
  def barcode_type
    barcode&.type || '2D'
  end

  def barcode_prefix
    barcode&.prefix || ''
  end
end

# Extend the Settings object with our custom methods
Settings.extend(SettingsExtensions)
