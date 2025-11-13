require 'capybara/rails'
require 'capybara/poltergeist'

# Ensure DISPLAY environment variable is set for PhantomJS
ENV['DISPLAY'] ||= ':99'

# Monkey-patch Cliver to skip version detection for PhantomJS
# This fixes "failed to detect theversion of the executable" error
module Cliver
  class Dependency
    alias_method :original_detect_version, :detect_version
    
    def detect_version(path)
      # Return a dummy version for PhantomJS to bypass version detection
      if path.to_s.include?('phantomjs')
        '2.1.1' # Return a valid version string
      else
        original_detect_version(path)
      end
    end
  end
end

# Configure Poltergeist to use PhantomJS
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    phantomjs: '/usr/bin/phantomjs',
    phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'],
    inspector: false,
    js_errors: false,
    debug: false,
    timeout: 60
  })
end

Capybara.javascript_driver = :poltergeist
