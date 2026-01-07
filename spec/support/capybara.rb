require 'capybara/rails'

ALLOW_JS_SPECS = ENV["ALLOW_JS_SPECS"].to_s.strip.match?(/\A(1|true|yes)\z/i)

RSpec.configure do |config|
  config.before(:suite) do
    # Request specs should be able to run in CI/containers without external
    # browser dependencies.
    Capybara.default_driver = :rack_test
    # NOTE: rack_test does not execute JavaScript. This repo intentionally does
    # not run JS-enabled specs in CI/containers.
    Capybara.javascript_driver = :rack_test unless ALLOW_JS_SPECS
  end

  config.before(:each, js: true) do
    next if ALLOW_JS_SPECS

    raise(
      "JS-driven specs (js: true) are not supported in CI/containers with the current rack_test setup. " \
      "To run them locally, set ALLOW_JS_SPECS=true and configure a real JS driver " \
      "(e.g. selenium with headless Chrome) plus the required browser dependencies."
    )
  end
end
