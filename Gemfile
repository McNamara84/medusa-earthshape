source 'https://rubygems.org'
ruby '3.2.6'
# source 'http://dream.misasa.okayama-u.ac.jp/rubygems/'
# Note: The above gem server is not publicly accessible
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.0'  # Upgraded to Rails 7.1.6
gem 'nokogiri', '~> 1.16'  # Ruby 3.1+ requires nokogiri 1.13+ (upgraded from 1.10.10)
gem 'loofah', '~> 2.22'  # Updated for nokogiri 1.16+ compatibility (upgraded from 2.3.1)
# gem 'psych', '~> 3.3.0'  # Removed - Rails 7.0+ uses Psych 4.x natively
# gem 'zeitwerk', '~> 2.3.0'  # Removed - Rails 7.0+ bundles Zeitwerk 2.6+

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.6'

# Use SCSS for stylesheets
gem 'sassc-rails'  # Rails 7.0: sass-rails replaced with sassc-rails

# Use Terser as compressor for JavaScript assets (Rails 7.0)
gem 'terser'  # Rails 7.0: Replaces uglifier

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 5.0'  # Rails 7.0 compatible

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby  # Incompatible with Ruby 2.4+
gem 'mini_racer', platforms: :ruby  # Modern replacement, easier to compile

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'  # Updated for Rails 5.1 (Mime::JSON fix)
#gem 'active_model_serializers'

# Rails 7.0: respond_with was extracted to the responders gem
gem 'responders', '~> 3.2'  # Rails 7.0: Required for respond_with (installed 3.2.0)

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

#Crossref
  gem 'crossref'

#DataCite/IGSN
  # datacite_doi_ify requires rest-client ~> 1.7 which uses mime-types < 3.0
  # mime-types 2.x is NOT compatible with Ruby 3.0 (_1, _2, _3 are reserved)
  # Options:
  # 1. Fork datacite_doi_ify and update dependencies
  # 2. Use newer rest-client gem and override dependency
  # gem 'datacite_doi_ify'
  gem 'rest-client', '~> 2.1'  # Ruby 3.0 compatible (uses mime-types 3.x)
  gem 'mime-types', '~> 3.6'   # Ruby 3.0 compatible (installed 3.6.1)

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
gem 'unicorn'

# Use puma for Capybara request specs (Rails 7.1 requires Puma 6+ for Rack 3)
gem 'puma', '~> 6.0'  # Rails 7.1 uses Rack 3 which requires Puma 6+

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise'
gem 'cancancan', '~> 3.6'  # Rails 7.0: Updated to 3.6+ (1.x deprecated)
gem 'kaminari'
gem 'draper'
gem 'paperclip'
gem 'barby'
gem 'rqrcode'
gem 'chunky_png'
gem 'alchemist', git: 'https://github.com/halogenandtoast/alchemist'
gem 'geonames'
gem 'rubyzip'
#gem 'oai'
gem 'comma'
gem 'acts-as-taggable-on', '~> 10.0'  # Rails 7.0 compatible (v10.0+ supports Rails 6.1-7.x)
gem 'exception_notification'
gem 'settingslogic'
# gem 'validates_existence'  # Rails 5.1: Removed - incompatible with Rails 5.1+ (belongs_to validation now built-in)
# Note: acts_as_mappable and with_recursive are from private gem server
# These gems are temporarily disabled for Docker deployment as they are not publicly available
# gem 'acts_as_mappable'
# gem 'with_recursive'
gem 'thinreports', '>= 0.8.0'
gem 'bootstrap-sass'
gem 'ransack'
gem 'whenever', require: false
gem 'acts_as_list', '~> 1.0'  # Updated for Rails 5 compatibility (was 0.4.0)
gem 'listen', '~> 3.3'  # Required by ActiveSupport file watcher (Rails 6.x)
gem 'builder'
gem 'ffi', '~> 1.15.0'  # Lock to version compatible with RubyGems 3.0.x (1.17+ requires RubyGems 3.3.22+)
gem 'test-unit', '~> 3.0'  # Required for rspec-rails with Ruby 2.2+
gem 'bootsnap', '>= 1.1.0', require: false  # Rails 5.2: Speeds up boot time
group :development, :test do
  gem 'rak'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 6.1.0'  # Rails 7.1 requires RSpec-Rails 6.x
  gem 'rails-controller-testing'  # Required for Rails 5.0+ (assigns, assert_template)
  gem 'spring', '~> 2.1.0'  # Lock to version compatible with Ruby 2.5 (v4+ requires Ruby 2.7+)
  gem 'guard-rspec', '>= 4.7.3', require: false  # Updated to support RSpec 3.9+
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
end

group :test do
  gem 'capybara', '>= 2.2.0'
  gem 'poltergeist', '~> 1.18.0'  # Updated to support PhantomJS 2.x
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'ci_reporter'
  gem 'factory_girl_rails'
  gem 'rspec_junit_formatter' # For CI test result reporting
end

gem 'active_link_to'
gem 'gmaps4rails'
