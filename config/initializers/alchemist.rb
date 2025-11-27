# frozen_string_literal: true

# Rails 7.0: Alchemist initialization must be deferred until after models are loaded
# Using after_initialize ensures this runs once at startup after Zeitwerk autoloading

module AlchemistMedusaConfig
  # Class variable persists across application reloads in development
  @@units_registered = false

  def self.units_registered?
    @@units_registered
  end

  def self.mark_registered!
    @@units_registered = true
  end

  def self.reset!
    @@units_registered = false
  end
end

Rails.application.config.after_initialize do
  # Initialize Alchemist before registering custom units
  Alchemist.setup

  # Check if Unit model has the required attributes (table may not exist during migrations)
  # Guard: Only register units once (Alchemist.register is not idempotent)
  if defined?(Unit) && Unit.table_exists? && Unit.attribute_method?(:name) && Unit.attribute_method?(:conversion)
    unless AlchemistMedusaConfig.units_registered?
      Unit.pluck(:name, :conversion).each do |name, conversion|
        Alchemist.register(:mass, name.to_sym, 1.to_d / conversion)
      end
      AlchemistMedusaConfig.mark_registered!
    end
  end
end
