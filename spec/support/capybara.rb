require 'capybara/rails'

RSpec.configure do |config|
  config.before(:suite) do
    # Request specs should be able to run in CI/containers without external
    # browser dependencies.
    Capybara.default_driver = :rack_test
    # NOTE: rack_test does not execute JavaScript. This repo intentionally does
    # not run JS-enabled specs in CI/containers.
    Capybara.javascript_driver = :rack_test
  end

  config.before(:each, js: true) do
    raise(
      "JS-driven specs (js: true) are not supported in CI/containers with the current rack_test setup. " \
      "To test JavaScript functionality, configure a real JS driver (e.g. selenium with headless Chrome) " \
      "and install the required browser dependencies."
    )
  end
end
