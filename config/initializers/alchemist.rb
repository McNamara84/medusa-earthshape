# frozen_string_literal: true

# Rails 7.0: Alchemist initialization must be deferred until after models are loaded
# Using after_initialize ensures this runs once at startup after Zeitwerk autoloading
# The guard prevents duplicate registrations if this file is reloaded

Rails.application.config.after_initialize do
  # Initialize Alchemist before registering custom units
  Alchemist.setup

  # Check if Unit model has the required attributes (table may not exist during migrations)
  # Guard: Only register units once (Alchemist.register is not idempotent)
  if defined?(Unit) && Unit.table_exists? && Unit.attribute_method?(:name) && Unit.attribute_method?(:conversion)
    unless @alchemist_units_registered
      Unit.pluck(:name, :conversion).each do |name, conversion|
        Alchemist.register(:mass, name.to_sym, 1.to_d / conversion)
      end
      @alchemist_units_registered = true
    end
  end
end
