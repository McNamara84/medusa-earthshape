require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    # Capybara-driven specs issue requests through the Rack stack and may use a
    # separate DB connection from the example. Transactions can make data
    # invisible to the app; truncation avoids that.
    #
    # Trade-off: truncation is slower than transactions. If performance becomes
    # a concern, we can revisit using transactions + shared connection, or opt-in
    # truncation only for specs that truly need multi-connection behavior.
    DatabaseCleaner.strategy = example.metadata[:type] == :request ? :truncation : :transaction

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
