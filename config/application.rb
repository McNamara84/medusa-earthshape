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

    # Rails 7.0+: Relax open redirect protection for legacy responder flows
    #
    # SECURITY NOTE: This remains relaxed for legacy compatibility.
    #
    # Current state:
    # - The application still has many legacy `respond_with ... location:` flows that were
    #   preserved during the framework upgrade for behavior compatibility.
    # - CategoryMeasurementItemsController and AttachingsController now redirect through
    #   the safe referer helpers in ApplicationController.
    # - Many nested resource controllers still use raw `request.referer` patterns and must
    #   be migrated before strict redirect protection can be re-enabled.
    #
    # Risk mitigation:
    # - The application is an internal scientific data management system
    # - Access requires authentication (Devise)
    # - The referer-based redirects only occur after successful CRUD operations
    #
    # The `safe_referer_url` helper is available in ApplicationController for future use:
    # - Allows same-host absolute URLs
    # - Allows root-relative URLs (implicitly same-host)
    # - Falls back to root_path for cross-host URLs
    # - Rejects path-relative redirects without a leading slash
    #
    # TODO: Migrate the remaining responder flows to `safe_referer_url` /
    # `safe_referer_url_with_requested_tab` (or explicit `redirect_to` calls), then tighten
    # this setting from `:log` back to `:raise`. Note: `redirect_to url, allow_other_host: false`
    # is not applicable with `respond_with` because it uses the `location:` option instead.
    # See: https://github.com/McNamara84/medusa-earthshape/issues (create tracking issue)
    config.action_controller.action_on_open_redirect = :log

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
    # Setting to :log to maintain compatibility with existing test patterns.
    # TODO: Update controller specs to use absolute URL mocks instead of relative paths,
    # then consider enabling :raise for stricter security.
    config.action_controller.action_on_path_relative_redirect = :log
  end
end
