# frozen_string_literal: true

# Config gem configuration
# See: https://github.com/rubyconfig/config
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
  # Setting: Settings.use_env = true allows overriding via ENV['Settings.section.key']
  config.use_env = false

  # Define ENV variable prefix
  config.env_prefix = 'SETTINGS'

  # Define ENV variable separator
  config.env_separator = '__'

  # Evaluate ERB in YAML config files
  config.evaluate_erb_in_yaml = true
end
