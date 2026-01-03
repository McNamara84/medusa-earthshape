source 'https://rubygems.org'
ruby '>= 4.0.0', '< 4.1'
# source 'http://dream.misasa.okayama-u.ac.jp/rubygems/'
# Note: The above gem server is not publicly accessible
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.1.0'  # Upgraded to Rails 8.1
gem 'nokogiri', '~> 1.16'  # Ruby 3.1+ requires nokogiri 1.13+ (upgraded from 1.10.10)
gem 'loofah', '~> 2.22'  # Updated for nokogiri 1.16+ compatibility (upgraded from 2.3.1)
# gem 'psych', '~> 3.3.0'  # Removed - Rails 7.0+ uses Psych 4.x natively
# gem 'zeitwerk', '~> 2.3.0'  # Removed - Rails 7.0+ bundles Zeitwerk 2.6+

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.6'

# Use SCSS for stylesheets
gem 'sassc-rails'  # Rails 7.0: sass-rails replaced with sassc-rails
gem 'sprockets-rails'  # Rails 8.0: Must be explicitly included (no longer default)

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
gem 'puma', '~> 7.1'  # Rails/Rack 3 compatible; allow update to Puma 7.1.x

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise'
gem 'cancancan', '~> 3.6'  # Rails 7.0: Updated to 3.6+ (1.x deprecated)
gem 'kaminari'
gem 'draper'
gem 'kt-paperclip', '~> 7.2'  # Maintained fork of Paperclip (Rails 7.x + Ruby 3.x compatible)
gem 'barby'
gem 'rqrcode'
gem 'chunky_png'
gem 'csv'  # Ruby 3.4: csv moved from default gem to bundled gem
gem 'bigdecimal', '~> 4.0'  # Ruby 3.4: bigdecimal moved from default gem to bundled gem
gem 'mutex_m'  # Ruby 3.4: mutex_m moved from default gem to bundled gem
gem 'base64'  # Ruby 3.4: base64 moved from default gem to bundled gem
gem 'drb'  # Ruby 3.4: drb moved from default gem to bundled gem

# Reporting stack dependency override (unblocks bigdecimal 4.x without downgrades)
gem 'ttfunk', path: 'vendor/gems/ttfunk-1.8.0'

gem 'alchemist', git: 'https://github.com/halogenandtoast/alchemist'
gem 'geonames'
gem 'rubyzip'
#gem 'oai'
gem 'comma'
gem 'acts-as-taggable-on', '~> 13.0'  # Rails 7.2 compatible (v13.0+ supports Rails 7.1-7.2)
gem 'exception_notification'
gem 'config'  # Settings management (replaces settingslogic)
# gem 'validates_existence'  # Rails 5.1: Removed - incompatible with Rails 5.1+ (belongs_to validation now built-in)
# Note: acts_as_mappable and with_recursive are from private gem server
# These gems are temporarily disabled for Docker deployment as they are not publicly available
# gem 'acts_as_mappable'
# gem 'with_recursive'
gem 'thinreports', '>= 0.8.0'
gem 'bootstrap', '~> 5.3'  # Bootstrap 5.3.x (upgraded from bootstrap-sass 3.4.1)
# gem 'bootstrap-sass'  # DEPRECATED: Bootstrap 3.x, replaced by 'bootstrap' gem
gem 'autoprefixer-rails', '>= 9.1.0'  # Required by Bootstrap 5 gem
gem 'ransack'
gem 'whenever', require: false
gem 'acts_as_list', '~> 1.0'  # Updated for Rails 5 compatibility (was 0.4.0)
gem 'listen', '~> 3.3'  # Required by ActiveSupport file watcher (Rails 6.x)
gem 'builder'
gem 'ffi', '~> 1.17'  # Allow update to latest 1.17.x
gem 'test-unit', '~> 3.0'  # Required for rspec-rails with Ruby 2.2+
gem 'bootsnap', '>= 1.1.0', require: false  # Rails 5.2: Speeds up boot time
group :development do
  gem 'rak'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'spring', '~> 4.4'  # Legacy; keep development-only to avoid test/runtime coupling
  gem 'guard-rspec', '>= 4.7.3', require: false  # Updated to support RSpec 3.9+
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
end

group :development, :test do
  gem 'rspec-rails', '~> 8.0'
  # Sorbet static type checker
  gem 'sorbet', require: false
  gem 'sorbet-runtime'
  gem 'tapioca', require: false  # RBI generator for gems and Rails
  gem 'rails-controller-testing'  # Required for Rails 5.0+ (assigns, assert_template)
end

group :test do
  gem 'capybara', '>= 2.2.0'
  gem 'poltergeist', '~> 1.18.0'  # Updated to support PhantomJS 2.x
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'ci_reporter'
  gem 'factory_bot_rails'  # Renamed from factory_girl_rails (Rails 7.2 compatible)
  gem 'rspec_junit_formatter' # For CI test result reporting
end

gem 'active_link_to'
gem 'gmaps4rails'
