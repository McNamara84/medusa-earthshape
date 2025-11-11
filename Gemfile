source 'https://rubygems.org'
# source 'http://dream.misasa.okayama-u.ac.jp/rubygems/'
# Note: The above gem server is not publicly accessible
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.11.3'  # Updated from 4.0.2 for Ruby 2.3 compatibility
gem 'loofah', '~> 2.3.1'  # Lock to older version compatible with nokogiri 1.6.x

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'  # Updated for Rails 4.2

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'  # Updated for Rails 4.2

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby  # Incompatible with Ruby 2.4+
gem 'mini_racer', platforms: :ruby  # Modern replacement, easier to compile

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
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

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise'
gem 'cancan'
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
gem 'acts_as_taggable_on'
gem 'exception_notification'
gem 'settingslogic'
gem 'validates_existence'
# Note: acts_as_mappable and with_recursive are from private gem server
# These gems are temporarily disabled for Docker deployment as they are not publicly available
# gem 'acts_as_mappable'
# gem 'with_recursive'
gem 'thinreports', '>= 0.8.0'
gem 'bootstrap-sass'
gem 'ransack'
gem 'whenever', require: false
gem 'acts_as_list'
gem 'builder'
gem 'test-unit', '~> 3.0'  # Required for rspec-rails with Ruby 2.2+
group :development, :test do
  gem 'rak'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.5.0'  # Updated from beta1 - stable version compatible with Rails 4.2 & Rake 13
  gem 'spring'
  gem 'guard-rspec', '>= 4.7.0', require: false  # Updated to support RSpec 3.5+
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
