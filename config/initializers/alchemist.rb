# frozen_string_literal: true

# Rails 7.0: Alchemist initialization must be deferred until after models are loaded
# Using after_initialize ensures this runs once at startup after Zeitwerk autoloading

module AlchemistMedusaConfig
  # Thread-safe initialization tracking using Mutex
  # Required for production environments with multi-threaded servers (e.g., Puma)
  @mutex = Mutex.new
  @units_registered = false

  class << self
    def units_registered?
      @mutex.synchronize { @units_registered }
    end

    def register_units_once
      @mutex.synchronize do
        return if @units_registered
        yield if block_given?
        @units_registered = true
      end
    end
  end
end

Rails.application.config.after_initialize do
  # Initialize Alchemist before registering custom units
  Alchemist.setup

  # Check if Unit model has the required attributes (table may not exist during migrations)
  # Guard: Only register units once (Alchemist.register is not idempotent)
  if defined?(Unit) && Unit.table_exists? && Unit.attribute_method?(:name) && Unit.attribute_method?(:conversion)
    AlchemistMedusaConfig.register_units_once do
      Unit.pluck(:name, :conversion).each do |name, conversion|
        Alchemist.register(:mass, name.to_sym, 1.to_d / conversion)
      end
    end
  end
end
