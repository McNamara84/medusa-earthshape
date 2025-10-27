desc "csv data moving for Docker (using Ruby CSV parser instead of PostgreSQL COPY)"

task :csv_data_moving_docker => :environment do
  require 'csv'
  
  work_dir = Pathname.new("/tmp/medusa_csv_files")
  
  unless work_dir.exist?
    puts "Warning: CSV work directory not found: #{work_dir}"
    return
  end
  
  # Define loading order to respect foreign key dependencies
  load_order = [
    "units",                              # Must be first (needed by measurement_categories, measurement_items)
    "measurement_categories",             # Needed by category_measurement_items
    "measurement_items",                  # Needed by category_measurement_items
    "category_measurement_items",
    "preparation_types",                  # Needed by preparation_for_classifications
    "classifications",                    # Needed by preparation_for_classifications
    "preparation_for_classifications",
    "box_types",
    "collectionmethods",
    "devices",
    "filetopics",
    "landuses",
    "physical_forms",
    "quantityunits",
    "stonecontainer_types",
    "techniques",
    "topographic_positions",
    "vegetations"
  ]
  
  # Get all CSV files and sort by defined order
  all_csv_files = Pathname.glob(work_dir.join("*.csv"))
  csv_files = []
  
  # Add files in specified order
  load_order.each do |table_name|
    file = all_csv_files.find { |f| f.basename(".csv").to_s == table_name }
    csv_files << file if file
  end
  
  # Add any remaining files not in load_order
  csv_files += (all_csv_files - csv_files)
  
  if csv_files.empty?
    puts "Warning: No CSV files found in #{work_dir}"
    return
  end
  
  puts "Loading #{csv_files.count} CSV files into database..."
  
  csv_files.each do |path|
    table_name = path.basename(".csv").to_s
    next if table_name == "users"  # Skip users.csv if exists
    
    begin
      # Check if table exists
      unless ActiveRecord::Base.connection.table_exists?(table_name)
        puts "  Skipping #{table_name}: table does not exist"
        next
      end
      
      # Read CSV file
      rows = CSV.read(path.to_s, headers: true, header_converters: :symbol)
      
      if rows.empty?
        puts "  Skipping #{table_name}: no data rows"
        next
      end
      
      puts "  Loading #{rows.count} rows into #{table_name}..."
      
      # Get the model class
      model_class = table_name.classify.constantize rescue nil
      
      if model_class
        # Use ActiveRecord model if available
        rows.each do |row|
          record = model_class.new(row.to_h)
          # Save without validations to allow empty fields in seed data
          record.save(validate: false)
        end
      else
        # Fall back to raw SQL insert
        rows.each do |row|
          columns = row.to_h.keys.join(", ")
          values = row.to_h.values.map { |v| ActiveRecord::Base.connection.quote(v) }.join(", ")
          ActiveRecord::Base.connection.execute("INSERT INTO #{table_name} (#{columns}) VALUES (#{values})")
        end
      end
      
      # Reset sequence
      max_id = ActiveRecord::Base.connection.select_value("SELECT MAX(id) FROM #{table_name}").to_i
      if max_id > 0
        ActiveRecord::Base.connection.execute("SELECT setval('#{table_name}_id_seq', #{max_id})")
      end
      
      puts "  ✓ Loaded #{table_name}"
      
    rescue => e
      puts "  ✗ Error loading #{table_name}: #{e.message}"
      # Continue with next file instead of failing completely
    end
  end
  
  puts "✓ CSV data loading completed"
end
