require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Medusa
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.0
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Rails 7.0: Zeitwerk is the only autoloader (Classic removed)
    # Ensure all autoloaded paths follow Zeitwerk naming conventions

    # Rails 7.0: Disable open redirect protection
    #
    # SECURITY NOTE: This setting is disabled because:
    # 1. The application uses `respond_with location: request.referer` pattern in 39 places
    #    across nested resource controllers for UX continuity after CRUD operations
    # 2. All these redirects use `adjust_url_by_requesting_tab()` which calls `safe_referer_url`
    #    to validate that the referer is from the same host before redirecting
    # 3. The application is an internal scientific data management system, not public-facing
    # 4. Refactoring all 39 locations to use `allow_other_host: true` would require significant
    #    changes to the responders gem integration
    #
    # The `safe_referer_url` helper in ApplicationController provides host validation:
    # - Allows same-host absolute URLs
    # - Allows relative URLs (implicitly same-host)
    # - Falls back to root_path for cross-host URLs
    #
    # TODO: Consider migrating to explicit `redirect_to url, allow_other_host: false` pattern
    # in a future refactoring effort.
    config.action_controller.raise_on_open_redirects = false
  end
end
