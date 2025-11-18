# Medusa - EarthShape Sample Management System

[![Test Suite](https://github.com/McNamara84/medusa-earthshape/actions/workflows/test.yml/badge.svg)](https://github.com/McNamara84/medusa-earthshape/actions/workflows/test.yml)

Medusa is a comprehensive web-based sample management system designed for geological and earth science research. It manages hierarchical collections of physical samples (stones), their containers (boxes), sampling locations (places), and analytical chemistry data.

## Features

- **Hierarchical Sample Management**: Organize samples in a tree structure (Collection → Place → Box → Stone)
- **Analytical Data**: Store and manage chemistry measurements and analyses
- **IGSN Registration**: Register samples with the International Geo Sample Number (IGSN) authority
- **Multi-format Export**: Export data as PML (Phml Markup Language), BibTeX, CSV, and PDF labels
- **File Attachments**: Attach images and documents to samples, with spatial coordinate mapping
- **Access Control**: User and group-based permissions with owner/group/guest read/write controls
- **REST API**: Full REST API with support for HTML, XML, and JSON formats
- **Tagging System**: Flexible categorization using tags
- **Bibliography Management**: Link samples to scientific publications

## System Requirements

- **Ruby**: 2.5.9
- **Rails**: 6.0.6.1
- **Database**: PostgreSQL 9.6 or higher
- **Server**: Linux/Unix-based system (tested on Ubuntu/Debian)
- **Web Server**: Apache 2.4+ with mod_proxy (or Nginx)
- **Application Server**: Unicorn

## Quick Start (Development)

### Option 1: Docker (Recommended for Local Testing)

The easiest way to run Medusa locally is using Docker:

**Windows (PowerShell):**
```powershell
.\start-docker.ps1
```

**Linux/Mac:**
```bash
docker compose up -d
```

**Access the application:**
- URL: http://localhost:3000
- Default login: `admin` / `admin123`

**Stop the application:**
```bash
docker compose down
```

See [DOCKER.md](DOCKER.md) for detailed Docker documentation. Windows users should also check [DOCKER-WINDOWS.md](DOCKER-WINDOWS.md).

### Option 2: Native Installation

#### Prerequisites

Install system dependencies:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y git ruby ruby-dev build-essential \
  postgresql postgresql-contrib libpq-dev nodejs \
  imagemagick libmagickwand-dev

# Install bundler
gem install bundler -v '~> 2.1'
```

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/McNamara84/medusa-earthshape.git
cd medusa-earthshape
```

2. **Install Ruby dependencies:**

```bash
bundle install
```

3. **Configure the database:**

```bash
cp config/database.yml.example config/database.yml
# Edit config/database.yml with your PostgreSQL credentials
```

4. **Configure the application:**

```bash
cp config/application.yml.example config/application.yml
# Edit config/application.yml (site name, admin email, etc.)
```

5. **Setup the database:**

```bash
bundle exec rake db:setup
```

6. **Start the development server:**

```bash
bundle exec rails server
```

Visit `http://localhost:3000` in your browser.

## Production Deployment

### Server Setup

#### 1. Install System Dependencies

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y git curl build-essential \
  postgresql postgresql-contrib libpq-dev \
  nodejs imagemagick libmagickwand-dev \
  apache2 apache2-dev

# Install Ruby via rbenv (recommended)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby 2.5.9
rbenv install 2.5.9
rbenv global 2.5.9
gem install bundler -v '~> 2.1'
```

#### 2. Setup PostgreSQL Database

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL console:
CREATE USER medusa WITH PASSWORD 'your_secure_password';
CREATE DATABASE medusa_production OWNER medusa;
GRANT ALL PRIVILEGES ON DATABASE medusa_production TO medusa;
\q
```

#### 3. Setup Application User

```bash
# Create deployment user
sudo useradd -m -s /bin/bash medusa
sudo su - medusa

# Generate SSH key for deployment
ssh-keygen -t rsa -b 4096 -C "medusa@yourserver.com"
```

#### 4. Deploy Application

**Option A: Manual Deployment**

```bash
# As medusa user
cd /srv/app
git clone https://github.com/McNamara84/medusa-earthshape.git medusa
cd medusa

# Install dependencies
bundle install --deployment --without development test

# Configure application
cp config/database.yml.example config/database.yml
cp config/application.yml.example config/application.yml

# Edit configuration files
nano config/database.yml
nano config/application.yml

# Setup database
RAILS_ENV=production bundle exec rake db:setup

# Precompile assets
RAILS_ENV=production bundle exec rake assets:precompile

# Create required directories
mkdir -p tmp/pids tmp/sockets log public/system
```

**Option B: Capistrano Deployment**

1. Configure deployment server:

```bash
# On your local machine
cp config/deploy/production.rb.example config/deploy/production.rb
# Edit config/deploy/production.rb with your server details
```

2. Setup server directories:

```bash
bundle exec cap production site:setup
```

3. Deploy:

```bash
bundle exec cap production deploy
```

#### 5. Configure Unicorn

Create production Unicorn configuration:

```bash
# Create config/unicorn/production.rb if not exists
mkdir -p /srv/app/medusa/shared/config/unicorn
```

Content for `config/unicorn/production.rb`:

```ruby
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 60
preload_app true

listen "127.0.0.1:3001"
pid "/srv/app/medusa/shared/tmp/pids/unicorn.pid"

stderr_path "/srv/app/medusa/shared/log/unicorn.error.log"
stdout_path "/srv/app/medusa/shared/log/unicorn.log"

before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
```

#### 6. Setup Systemd Service

Create `/etc/systemd/system/medusa.service`:

```ini
[Unit]
Description=Medusa Unicorn Server
After=postgresql.service
Requires=postgresql.service

[Service]
Type=forking
User=medusa
WorkingDirectory=/srv/app/medusa/current
Environment=RAILS_ENV=production
Environment=RAILS_ROOT=/srv/app/medusa/current

ExecStart=/home/medusa/.rbenv/shims/bundle exec unicorn -c /srv/app/medusa/current/config/unicorn/production.rb -E production -D
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -QUIT $MAINPID

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable medusa
sudo systemctl start medusa
sudo systemctl status medusa
```

#### 7. Configure Apache as Reverse Proxy

Create `/etc/apache2/sites-available/medusa.conf`:

```apache
<VirtualHost *:80>
    ServerName your-domain.com
    ServerAdmin admin@your-domain.com

    # Enable proxy modules
    ProxyRequests Off
    ProxyPreserveHost On
    
    <Location /medusa>
        ProxyPass http://localhost:3001/medusa
        ProxyPassReverse http://localhost:3001/medusa
    </Location>
    
    <Location /assets>
        ProxyPass http://localhost:3001/medusa/assets
        ProxyPassReverse http://localhost:3001/medusa/assets
    </Location>

    ErrorLog ${APACHE_LOG_DIR}/medusa-error.log
    CustomLog ${APACHE_LOG_DIR}/medusa-access.log combined
</VirtualHost>
```

Enable the site:

```bash
# Enable required Apache modules
sudo a2enmod proxy proxy_http headers

# Enable site
sudo a2ensite medusa
sudo systemctl reload apache2
```

#### 8. Setup SSL with Let's Encrypt (Optional but Recommended)

```bash
sudo apt-get install certbot python3-certbot-apache
sudo certbot --apache -d your-domain.com
sudo systemctl reload apache2
```

### Post-Deployment Configuration

#### Create Initial Admin User

```bash
cd /srv/app/medusa/current
RAILS_ENV=production bundle exec rails console

# In Rails console:
user = User.new(
  username: "admin",
  email: "admin@example.com",
  password: "your_secure_password",
  password_confirmation: "your_secure_password",
  administrator: true
)
user.save!
exit
```

#### Configure Backups

Setup automated backups using the provided rake tasks:

```bash
# Add to crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd /srv/app/medusa/current && RAILS_ENV=production bundle exec rake db:dump >> /var/log/medusa-backup.log 2>&1
```

### Maintenance

#### Update Application

```bash
# With Capistrano
bundle exec cap production deploy

# Manual update
cd /srv/app/medusa/current
git pull origin main
bundle install --deployment
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile
sudo systemctl restart medusa
```

#### Check Logs

```bash
# Application logs
tail -f /srv/app/medusa/shared/log/production.log

# Unicorn logs
tail -f /srv/app/medusa/shared/log/unicorn.log

# System service logs
sudo journalctl -u medusa -f
```

#### Database Backup/Restore

```bash
# Backup
RAILS_ENV=production bundle exec rake db:dump

# Restore
RAILS_ENV=production bundle exec rake db:load
```

## Development

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/stone_spec.rb

# Auto-run tests on file changes (recommended)
bundle exec guard
```

### Code Style

- All code, comments, and documentation must be in **English**
- Follow Ruby style guidelines
- Use meaningful variable and method names
- Write tests for new features

### Common Rake Tasks

```bash
# Export records in LaTeX format
rake db:dump_records:latex

# Export records as BibTeX
rake db:dump_records:bib

# Update record properties
rake update_record_properties

# Database operations
rake db:dump          # Backup database
rake db:load          # Restore database
```

## API Usage

Medusa provides a REST API for all resources. Authentication uses HTTP Basic Auth.

### Example API Calls

```bash
# Get stones (JSON)
curl -u username:password https://your-domain.com/medusa/stones.json

# Get specific stone
curl -u username:password https://your-domain.com/medusa/stones/123.json

# Get analyses in PML format
curl -u username:password https://your-domain.com/medusa/analyses/456.pml

# Create a new stone
curl -u username:password -X POST \
  -H "Content-Type: application/json" \
  -d '{"stone": {"name": "Sample123", "box_id": 1, ...}}' \
  https://your-domain.com/medusa/stones.json
```

## Troubleshooting

### Common Issues

**Database Connection Errors:**
- Check `config/database.yml` credentials
- Verify PostgreSQL is running: `sudo systemctl status postgresql`
- Check PostgreSQL logs: `sudo tail -f /var/log/postgresql/postgresql-*.log`

**Asset Issues:**
- Recompile assets: `RAILS_ENV=production bundle exec rake assets:precompile`
- Clear asset cache: `RAILS_ENV=production bundle exec rake assets:clobber`

**Permission Errors:**
- Ensure proper file ownership: `sudo chown -R medusa:medusa /srv/app/medusa`
- Check directory permissions for `tmp/`, `log/`, `public/system/`

**Unicorn Won't Start:**
- Check logs: `tail -f /srv/app/medusa/shared/log/unicorn.error.log`
- Verify PID file location exists: `mkdir -p /srv/app/medusa/shared/tmp/pids`
- Check port availability: `sudo netstat -tulpn | grep 3001`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Write tests for your changes
4. Commit your changes (`git commit -am 'Add new feature'`)
5. Push to the branch (`git push origin feature/my-feature`)
6. Create a Pull Request

## License

TODO

## Support

For issues and questions:
- Create an issue on GitHub
- Contact: [your contact information]

## Credits

Developed for the EarthShape project - A collaborative research initiative in earth science.

## Recent Updates

**November 2025**: Successfully upgraded from Rails 4.0.2 to Rails 6.1.7.10 (LTS)
- Complete upgrade path: Rails 4.0 → 4.2 → 5.0 → 5.1 → 5.2 → 6.0 → 6.1
- Ruby upgraded: 2.1.10 → 2.3.8 → 2.4.10 → 2.5.9
- 100% test suite passing (1318 tests)
- CI/CD verified on GitHub Actions
- See `UPGRADE-PLAN.md` for detailed upgrade history
