# Use Ruby 2.5.9 (last stable 2.5.x version)
FROM ruby:2.5.9

# Fix Debian Buster repositories (EOL - moved to archive)
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list

# Install system dependencies including PhantomJS from Debian repos
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    imagemagick \
    libmagickwand-dev \
    git \
    xvfb \
    phantomjs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler 1.17.3 (compatible with Ruby 2.3-2.4)
RUN gem install bundler -v '1.17.3'

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies (Gemfile now has problematic gems commented out)
RUN bundle config set --local without 'development test' && \
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
