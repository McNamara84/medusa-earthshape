# Rails 7.0: Alchemist initialization must be deferred until after models are loaded
# Using to_prepare ensures this runs after Zeitwerk autoloading

Rails.application.config.to_prepare do
  # Initialize Alchemist before registering custom units
  Alchemist.setup

  # Check if Unit model has the required attributes (table may not exist during migrations)
  if defined?(Unit) && Unit.table_exists? && Unit.attribute_method?(:name) && Unit.attribute_method?(:conversion)
    Unit.pluck(:name, :conversion).each do |name, conversion|
      Alchemist.register(:mass, name.to_sym, 1.to_d / conversion)
    end
  end
end
