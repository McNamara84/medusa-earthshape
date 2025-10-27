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

# Create admin user and associated records
admin = User.create(username: 'admin', administrator: true, email: Settings.admin.email, password: Settings.admin.initial_password, password_confirmation: Settings.admin.initial_password)
admin_group = Group.create(name: 'admin')
admin_group.users << admin
admin_box = Box.create(name: 'admin')
admin_box.user = admin
admin_box.group = admin_group
admin.box_id = admin_box.id
admin.save 