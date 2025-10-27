#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Clean up problematic gems from Gemfile.lock if they exist
sed -i '/acts_as_mappable/d' /app/Gemfile.lock 2>/dev/null || true
sed -i '/with_recursive/d' /app/Gemfile.lock 2>/dev/null || true
sed -i '/dream.misasa.okayama-u.ac.jp/d' /app/Gemfile.lock 2>/dev/null || true

# Wait for database to be ready
echo "Waiting for database..."
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Database is ready!"

# Check if database exists and has tables
if ! bundle exec rails runner "ActiveRecord::Base.connection" 2>/dev/null; then
  echo "Database connection failed, attempting to create..."
  bundle exec rake db:create
fi

# Check if database needs setup
TABLE_COUNT=$(bundle exec rails runner "puts ActiveRecord::Base.connection.tables.count" 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" = "0" ] || [ "$TABLE_COUNT" = "" ]; then
  echo "Database is empty, running setup..."
  
  # Run database setup
  bundle exec rake db:schema:load
  
  # Check if seeds should be run
  if [ -f "db/seeds.rb" ]; then
    echo "Running database seeds..."
    bundle exec rake db:seed || echo "Warning: Seed failed, continuing anyway..."
  fi
else
  echo "Database already set up, running migrations..."
  bundle exec rake db:migrate
fi

# Execute the main command
exec "$@"
