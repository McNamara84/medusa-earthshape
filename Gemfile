source 'https://rubygems.org'
# source 'http://dream.misasa.okayama-u.ac.jp/rubygems/'
# Note: The above gem server is not publicly accessible
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.6', '>= 6.0.6.1'  # Upgraded from 5.2.8.1 - Rails 6.0 LTS version
gem 'nokogiri', '~> 1.10.10'  # Lock to version compatible with Ruby 2.5 (1.13+ requires Ruby 2.6+)
gem 'loofah', '~> 2.3.1'  # Lock to older version compatible with nokogiri 1.10
gem 'psych', '~> 3.3.0'  # Lock to version 3.x for mini_racer compatibility (4.x+ have safe_load issues with libv8-node)
gem 'zeitwerk', '~> 2.3.0'  # Rails 6.0 autoloader - lock to 2.3.x for Ruby 2.5 compatibility

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'  # Updated for Rails 4.2

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2'  # Updated for Rails 5.1 compatibility

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

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

#Crossref
  gem 'crossref'

#DataCite/IGSN
  gem 'datacite_doi_ify'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
gem 'unicorn'

# Use puma for Capybara request specs (Rails 5.1+ default)
gem 'puma', '~> 5.6'  # Lock to 5.x for Capybara 3.35.3 compatibility (6.x changed Events API)

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise'
gem 'cancancan', '~> 1.10'  # Rails 5.1: Replaced cancan with cancancan (maintained fork)
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
gem 'acts-as-taggable-on', '~> 6.5.0'  # Rails 5.2 compatible (v4.0.0 has class_name bug with Rails 5.2)
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
  gem 'rspec-rails', '~> 4.0.0'  # Rails 6.0 requires RSpec-Rails 4.0+
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
