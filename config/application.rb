require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Medusa
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 8.1
    config.load_defaults 8.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Rails 7.2: Zeitwerk is the only autoloader
    # Ensure all autoloaded paths follow Zeitwerk naming conventions

    # Open redirect protection
    #
    # We rely on ApplicationController#safe_referer_url which only allows same-origin
    # redirects and normalizes relative paths.
    config.action_controller.action_on_open_redirect = :raise

    # Rails 8.1: Path-relative redirect protection
    #
    # Rails 8.1 introduces stricter protection against path-relative redirects
    # (e.g., redirecting to "some/path" instead of "/some/path" or absolute URLs).
    # This is a security feature to prevent open redirect attacks through relative paths.
    #
    # The default in Rails 8.1 is :raise, but our tests use mock referers like
    # "where_i_came_from" which are path-relative. In production, request.referer
    # always provides absolute URLs, so this is a test-only concern.
    #
    # Stricter security: disallow path-relative redirects ("some/path")
    # Use absolute URLs or leading-slash paths ("/some/path").
    config.action_controller.action_on_path_relative_redirect = :raise
  end
end
