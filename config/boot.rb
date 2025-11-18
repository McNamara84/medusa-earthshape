ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'logger' # Rails 6.0: Explicit Logger require for Ruby 2.5 compatibility
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
