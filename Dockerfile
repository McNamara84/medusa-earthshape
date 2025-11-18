# Use Ruby 2.7.8 (last stable 2.7.x version)
# Based on Debian Bullseye (11)
FROM ruby:2.7.8

# Debian Bullseye repositories are still active (no archive fix needed)

# Install system dependencies (PhantomJS not available in Bullseye, but not needed for production)
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    imagemagick \
    libmagickwand-dev \
    git \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Note: PhantomJS was available in Debian Buster but removed in Bullseye
# It's only needed for Poltergeist tests which can run without it or use Selenium/Capybara alternatives

# Set working directory
WORKDIR /app

# Install bundler 2.1.4 (compatible with Ruby 2.7, RubyGems 3.3+ for pg 1.6+)
RUN gem update --system 3.3.22 && \
    gem install bundler -v '2.1.4'

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies (including test gems for CI/CD)
# Only exclude development group (IRB, debugging tools not needed in container)
RUN bundle config set --local without 'development' && \
    bundle install --jobs 4 --retry 3

# Copy the application code
COPY . .

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

# Add entrypoint script
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

# Expose port 3000
EXPOSE 3000

# Default command (can be overridden by docker-compose.yml)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
