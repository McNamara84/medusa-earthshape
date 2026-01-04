require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    # Capybara-driven specs issue requests through the Rack stack and may use a
    # separate DB connection from the example. Transactions can make data
    # invisible to the app; truncation avoids that.
    DatabaseCleaner.strategy = example.metadata[:type] == :request ? :truncation : :transaction

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
