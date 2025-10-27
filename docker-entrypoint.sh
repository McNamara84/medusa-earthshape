#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

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
  
  # Run seeds to load CSV data and create admin user
  if [ -f "db/seeds.rb" ]; then
    echo "Running database seeds (loading CSV data and creating admin user)..."
    if bundle exec rake db:seed; then
      echo "✓ Database seeded successfully"
    else
      echo "✗ Seeding failed, creating minimal admin user..."
      # Fallback: Create admin user manually if seeding fails
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
          puts '✓ Admin user created: admin / admin123'
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
