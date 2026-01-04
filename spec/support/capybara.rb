require 'capybara/rails'

RSpec.configure do |config|
  config.before(:suite) do
    # Request specs should be able to run in CI/containers without external
    # browser dependencies.
    Capybara.default_driver = :rack_test
    Capybara.javascript_driver = :rack_test
  end
end
