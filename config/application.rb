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

    # Rails 7.0: Disable open redirect protection for legacy request.referer usage
    # The application uses respond_with location: request.referer in many controllers
    # This pattern is safe in this context as it only redirects to the referring page
    config.action_controller.raise_on_open_redirects = false
  end
end
