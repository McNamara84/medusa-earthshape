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
    # SECURITY NOTE: This setting is disabled for legacy compatibility.
    #
    # Current state:
    # - The application uses `respond_with location: request.referer` pattern in 39 places
    #   across nested resource controllers for UX continuity after CRUD operations
    # - Only 1 controller has been migrated to use `safe_referer_url`:
    #   - CategoryMeasurementItemsController (move_to_top, destroy)
    # - AttachingsController passes raw `request.referer` to `adjust_url_by_requesting_tab()`
    #   (a URL utility that only manipulates query params, does not validate hosts)
    # - The remaining 37 locations still use raw `request.referer` without validation
    #
    # Risk mitigation:
    # - The application is an internal scientific data management system
    # - Access requires authentication (Devise)
    # - The referer-based redirects only occur after successful CRUD operations
    #
    # The `safe_referer_url` helper is available in ApplicationController for future use:
    # - Allows same-host absolute URLs
    # - Allows relative URLs (implicitly same-host)
    # - Falls back to root_path for cross-host URLs
    #
    # TODO: Migrate all 39 locations to use `respond_with @resource, location: safe_referer_url`
    # pattern (for respond_with usage) or `redirect_to safe_referer_url` (for direct redirects),
    # then re-enable this protection. Note: `redirect_to url, allow_other_host: false` is not
    # applicable with respond_with as it uses the `location:` option which doesn't support
    # the allow_other_host parameter.
    # See: https://github.com/McNamara84/medusa-earthshape/issues (create tracking issue)
    config.action_controller.raise_on_open_redirects = false
  end
end
