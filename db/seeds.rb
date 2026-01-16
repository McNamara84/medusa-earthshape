# Setup work directory for CSV processing
work_dir = Pathname.new("/tmp/medusa_csv_files")

# Create and populate work directory if needed
if !work_dir.exist? || Dir.glob(work_dir.join("*.csv")).empty?
  FileUtils.mkdir_p(work_dir) unless work_dir.exist?
  csv_dir = Rails.root.join("db", "csvs")
  array_csv = Pathname.glob(csv_dir.join("*.csv"))
  FileUtils.cp(array_csv, work_dir) if array_csv.any?
end

# Load CSV data into database
# Use Docker-compatible task that reads CSV via Ruby instead of PostgreSQL COPY
Rake::Task[:csv_data_moving_docker].invoke

# Clean up work directory (commented out to keep files for future runs)
# FileUtils.rm_r(work_dir)

# Create test users (admin + non-admin) and associated records

def ensure_user_with_group_and_box!(username:, administrator:, email:, password:, group_name:, box_name:)
  user = User.find_or_initialize_by(username: username)
  user.administrator = administrator
  user.email = email

  # Always set the password to ensure it matches the expected value
  # This is important for CI/E2E tests where we need a known password
  user.password = password
  user.password_confirmation = password

  user.save!

  group = Group.find_or_create_by!(name: group_name)
  GroupMember.find_or_create_by!(group: group, user: user)

  box = Box.find_or_create_by!(name: box_name)
  box.user = user
  box.group = group
  box.save!

  if user.box_id != box.id
    user.update!(box_id: box.id)
  end

  user
end

admin_email = ENV.fetch('MEDUSA_ADMIN_EMAIL', Settings.admin.email)
admin_password = ENV.fetch('MEDUSA_ADMIN_PASSWORD', Settings.admin.initial_password)

test_email = ENV.fetch('MEDUSA_TEST_EMAIL', 'test@medusa-dev.local')
test_password = ENV.fetch('MEDUSA_TEST_PASSWORD', 'test123')

ensure_user_with_group_and_box!(
  username: 'admin',
  administrator: true,
  email: admin_email,
  password: admin_password,
  group_name: 'admin',
  box_name: 'admin'
)

ensure_user_with_group_and_box!(
  username: 'test',
  administrator: false,
  email: test_email,
  password: test_password,
  group_name: 'test',
  box_name: 'test'
)

puts "[OK] Seeded users: admin / #{admin_password} and test / #{test_password}"