# frozen_string_literal: true

# Config gem configuration
# See: https://github.com/rubyconfig/config
#
# Note: In Rails, the config gem's Railtie automatically loads settings from:
#   - config/settings.yml (base settings)
#   - config/settings/#{Rails.env}.yml (environment-specific overrides)
#   - config/settings.local.yml (local overrides, gitignored)
# No explicit call to Config.load_and_set_settings is needed.

Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'

  # Ability to remove elements of the array set in earlier loaded settings file.
  # For example, with the following settings:
  #   config/settings.yml: array: [ 'element1', 'element2' ]
  #   config/settings/development.yml: array: [ '--element2', 'element3' ]
  # The final result will be: ['element1', 'element3']
  config.knockout_prefix = nil

  # Overwrite arrays by default (merge when false)
  config.overwrite_arrays = true

  # Load environment variables from the `ENV` object
  # When enabled (`use_env = true`), allows overriding settings via ENV variables
  # with format ENV['SETTINGS__section__key'] (using env_prefix and env_separator below)
  config.use_env = false

  # Define ENV variable prefix
  config.env_prefix = 'SETTINGS'

  # Define ENV variable separator
  config.env_separator = '__'

  # Evaluate ERB in YAML config files
  config.evaluate_erb_in_yaml = true
end
