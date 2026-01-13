#!/bin/bash
set -e

# Ensure gems are installed (fixes volume mount override issue)
# When ./app is mounted, bundled gems from image are not accessible
# Run bundle check first, install only if needed
echo "Checking bundle..."
if ! bundle check > /dev/null 2>&1; then
  echo "Installing missing gems..."
  bundle install --jobs 4 --retry 3
else
  echo "Bundle check passed"
fi

# Start Xvfb (virtual display) for legacy Poltergeist tests
# Note: PhantomJS is not available in Debian Bullseye (see Dockerfile lines 19-24)
# Poltergeist tests are skipped in CI, but Xvfb is kept for local compatibility
# Run in background and save PID for cleanup
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=$!

# Wait for Xvfb to be ready
sleep 2

# Function to cleanup on exit
cleanup() {
  echo "Shutting down Xvfb..."
  kill $XVFB_PID 2>/dev/null || true
}
trap cleanup EXIT

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Ensure database.yml exists when the repo is bind-mounted.
# The image build creates config/database.yml, but a bind mount can hide it.
if [ ! -f /app/config/database.yml ]; then
  if [ -f /app/config/database.yml.docker ]; then
    echo "config/database.yml missing - creating from config/database.yml.docker"
    cp /app/config/database.yml.docker /app/config/database.yml
  else
    echo "[ERROR] config/database.yml missing and no docker template found"
    exit 1
  fi
fi

# Wait for database to be ready
# First, check if PostgreSQL server is accepting connections (without requiring specific database)
echo "Waiting for PostgreSQL server..."
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "postgres" -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "PostgreSQL server is ready!"

# Create database if it doesn't exist
echo "Checking if database '$DATABASE_NAME' exists..."
if ! PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c '\q' 2>/dev/null; then
  echo "Database '$DATABASE_NAME' does not exist, creating..."
  bundle exec rake db:create
  echo "[OK] Database created"
fi

echo "Database is ready!"

# Precompile assets in production (only if not already done)
if [ "$RAILS_ENV" = "production" ] && [ ! -d "public/assets" ]; then
  echo "Precompiling assets for production..."
  bundle exec rake assets:precompile
  echo "[OK] Assets precompiled"
fi

# Check if database needs setup
TABLE_COUNT=$(bundle exec rails runner "puts ActiveRecord::Base.connection.tables.count" 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" = "0" ] || [ "$TABLE_COUNT" = "" ]; then
  echo "Database is empty, running setup..."
  
  # Create database for current environment
  bundle exec rake db:create 2>/dev/null || true
  
  # In development, also create test database to prevent Rails 6.1 schema:load from failing
  # (Rails 6.1 db:schema:load iterates all environments in database.yml)
  if [ "$RAILS_ENV" = "development" ]; then
    echo "Creating test database for development environment..."
    bundle exec rake db:create RAILS_ENV=test 2>/dev/null || true
  fi
  
  # Run database setup (schema load)
  bundle exec rake db:schema:load
  
  # Run seeds to load CSV data and create admin user
  if [ -f "db/seeds.rb" ]; then
    echo "Running database seeds (loading CSV data and creating admin user)..."
    if bundle exec rake db:seed; then
      echo "[OK] Database seeded successfully"
    else
      echo "[ERROR] Seeding failed, creating minimal users..."
      # Fallback: Create users manually if seeding fails
      bundle exec rails runner "
        unless User.exists?(username: 'admin')
          admin = User.create!(
            username: 'admin',
            administrator: true,
            email: 'admin@medusa-dev.local',
            password: 'admin123',
            password_confirmation: 'admin123'
          )
          admin_group = Group.create!(name: 'admin')
          admin_group.users << admin
          admin_box = Box.create!(name: 'admin')
          admin_box.user = admin
          admin_box.group = admin_group
          admin.box_id = admin_box.id
          admin.save!
          puts '[OK] Admin user created: admin / admin123'
        end

        unless User.exists?(username: 'test')
          test_user = User.create!(
            username: 'test',
            administrator: false,
            email: 'test@medusa-dev.local',
            password: 'test123',
            password_confirmation: 'test123'
          )
          test_group = Group.create!(name: 'test')
          test_group.users << test_user
          test_box = Box.create!(name: 'test')
          test_box.user = test_user
          test_box.group = test_group
          test_user.box_id = test_box.id
          test_user.save!
          puts '[OK] Test user created: test / test123'
        end
      "
    fi
  fi
else
  echo "Database already set up, running migrations..."
  bundle exec rake db:migrate
fi

# Execute the main command
exec "$@"