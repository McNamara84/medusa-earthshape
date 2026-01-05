require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    # These request specs run in-process (Capybara rack_test + Rails integration),
    # so they share the DB connection and can safely use transactions.
    #
    # Opt-in truncation per-example if a spec truly needs multi-connection
    # behavior (e.g. external drivers): `it "...", :truncation do ... end`.
    DatabaseCleaner.strategy = example.metadata[:truncation] ? :truncation : :transaction

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
