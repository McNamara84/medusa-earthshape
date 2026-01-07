# Use Ruby 4.0 - Based on Debian Bookworm (12)
FROM ruby:4.0

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    imagemagick \
    libmagickwand-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler 2.3.22 (from Gemfile.lock BUNDLED WITH)
# Requires RubyGems 3.3+ for pg gem 1.6+ native extension compatibility
RUN gem update --system 3.3.22 && \
    gem install bundler -v '2.3.22'

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# If the bundle uses local path gems, they must be present before `bundle install`
COPY vendor/gems/ttfunk-1.8.0 vendor/gems/ttfunk-1.8.0

# Install dependencies (including test gems for CI/CD)
# Only exclude development group (IRB, debugging tools not needed in container)
RUN bundle config set --local without 'development' && \
    bundle install --jobs 4 --retry 3

# Copy the application code
COPY . .

# Create production database.yml from template
# This file uses environment variables for database configuration
RUN cp config/database.yml.production config/database.yml

# Temporarily comment out unavailable gems in models
# acts_as_mappable and with_recursive are from private gem server
RUN sed -i 's/^\(\s*\)acts_as_mappable/\1# acts_as_mappable # Temporarily disabled - gem not available/' app/models/place.rb || true
RUN find app/models -name "*.rb" -exec sed -i 's/^\(\s*\)with_recursive/\1# with_recursive # Temporarily disabled/' {} \; || true

# Create necessary directories including CSV work directory
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log public/system db/csvs /tmp/medusa_csv_files

# Copy CSV seed files to work directory for database seeding
# Set permissions so PostgreSQL can read them (PostgreSQL runs with different user)
RUN if [ -d "db/csvs" ] && [ "$(ls -A db/csvs/*.csv 2>/dev/null)" ]; then \
      cp db/csvs/*.csv /tmp/medusa_csv_files/ && \
      chmod 644 /tmp/medusa_csv_files/*.csv && \
      chmod 755 /tmp/medusa_csv_files || true; \
    fi

# Precompile assets (will be done in entrypoint for development)
# RUN RAILS_ENV=production bundle exec rake assets:precompile

# Make entrypoint script executable
# The entrypoint is configured in docker-compose.yml (line 20), not in Dockerfile
# CI uses docker-compose.override.yml to disable the entrypoint and avoid permission issues
RUN chmod +x /app/docker-entrypoint.sh

# Expose port 3000
EXPOSE 3000

# Default command (can be overridden by docker-compose.yml)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
