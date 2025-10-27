desc "CSV data moving"

task :csv_data_moving => :environment do
  work_dir = Pathname.new("/tmp/medusa_csv_files")
  Pathname.glob(work_dir.join("*.csv")) do |path|
    next if path.basename.to_s == "users.csv"
    
    table_name = path.basename(".csv").to_s
    quoted_table = ActiveRecord::Base.connection.quote_table_name(table_name)
    quoted_path = ActiveRecord::Base.connection.quote(path.to_s)
    
    ActiveRecord::Base.connection.execute("COPY #{quoted_table} FROM #{quoted_path} WITH CSV HEADER")
    
    max_next_id = ActiveRecord::Base.connection.select_value("
      SELECT MAX(id)
      FROM #{quoted_table}
    ").to_i
    next if max_next_id == 0
    
    sequence_name = "#{table_name}_id_seq"
    quoted_sequence_name = ActiveRecord::Base.connection.quote(sequence_name)
    ActiveRecord::Base.connection.execute("
      SELECT setval(#{quoted_sequence_name}, #{max_next_id})
    ")
  end
  
  # users = CSV.table("#{work_dir}/users.csv")
  
  # users.each do |row|
  #   row << { password: "admin", password_confirmation: "admin" }
  #   User.create(row.to_h)
  # end
  
  # user_max_next_id = ActiveRecord::Base.connection.select_value("
  #   SELECT MAX(id)
  #   FROM users
  # ").to_i
    
  # ActiveRecord::Base.connection.execute("
  #   SELECT setval('users_id_seq', #{user_max_next_id})
  # ")
end