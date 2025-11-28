# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
# require 'rspec/autorun'  # Removed - deprecated when running via 'rspec' command (RSpec 3.5+)

# Load support files BEFORE RSpec configuration
# This defines ControllerSpecHelper, RequestSpecHelper, etc.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# Rails 6.1+: maintain_test_schema! loads schema.rb if no migrations have run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  
  # Include Devise test helpers FIRST, then custom helpers
  # This ensures ControllerSpecHelper.sign_in can call super
  config.include Devise::Test::ControllerHelpers, type: :controller
  # CRITICAL: Only include Capybara::DSL for request specs, NOT controller specs
  # Including globally causes controller specs to hang indefinitely
  config.include Capybara::DSL, type: :request
  
  config.include ControllerSpecHelper, type: :controller
  config.include RequestSpecHelper, type: :request

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # Rails 7.1+: use fixture_paths (array) instead of fixture_path (singular)
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  
  # Automatically infer spec type from file location (e.g. spec/controllers -> type: :controller)
  # Required for RSpec 3.5+ to properly include Devise helpers
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:all) do
    FactoryBot.reload
  end
end
