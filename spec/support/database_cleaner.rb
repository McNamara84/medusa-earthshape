require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    # Default for all specs in this repo is :transaction (fast, runs in-process).
    # Use :truncation only for examples that truly require multi-connection
    # behavior (e.g. external drivers): `it "...", :truncation do ... end`.
    #
    DatabaseCleaner.strategy = example.metadata[:truncation] ? :truncation : :transaction

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
