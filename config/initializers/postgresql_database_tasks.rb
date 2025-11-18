module ActiveRecord
  module Tasks
    class PostgreSQLDatabaseTasks
      def drop
      	puts "dropping database..."
        establish_master_connection
        # Rails 6.1: use db_config.database instead of configuration['database']
        # Terminate idle connections before dropping database
        connection.select_all "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where datname='#{db_config.database}' AND state='idle';"
        connection.drop_database(db_config.database)
      end
    end
  end
end
