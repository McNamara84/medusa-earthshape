# This file is copied to spec/ when you run 'rails generate rspec:install'
# In container setups the web service often exports RAILS_ENV=development.
# Specs must run in test mode regardless.
ENV["RAILS_ENV"] ||= "test"
ENV["RACK_ENV"] ||= "test"

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
  
  # Rails 8.0: Ensure routes are loaded before Devise test helpers
  # This is a workaround for https://github.com/heartcombo/devise/issues/5705
  # Rails 8.0 uses deferred route drawing which causes Devise.mappings to be empty
  # until routes are actually loaded
  config.before(:each, type: :controller) do
    Rails.application.reload_routes_unless_loaded
  end

  config.before(:each, type: :request) do
    Rails.application.reload_routes_unless_loaded
  end
  
  # Include Devise test helpers FIRST, then custom helpers
  # This ensures ControllerSpecHelper.sign_in can call super
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Request specs (used with Capybara rack_test in this repo) should use Devise
  # integration helpers to ensure the session is correctly established.
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Request specs run through Capybara (rack_test). Use Warden test helpers for
  # stable authentication without depending on the login form markup.
  config.include Warden::Test::Helpers, type: :request
  config.after(:each, type: :request) { Warden.test_reset! }
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
  config.use_transactional_fixtures = false

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
