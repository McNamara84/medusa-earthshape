# frozen_string_literal: true

# Fix for Ruby 2.7 keyword argument deprecation warning with pg gem 1.6.x
# Rails 6.1 PostgreSQL adapter passes hash as positional argument but pg 1.6 expects keyword arguments
# This monkey-patches Rails to use keyword argument splat operator

if RUBY_VERSION >= '2.7.0'
  require 'active_record/connection_adapters/postgresql_adapter'
  
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
    # Override update_typemap_for_default_timezone to use keyword argument splat
    def update_typemap_for_default_timezone
      if @default_timezone != ActiveRecord::Base.default_timezone && @timestamp_decoder
        decoder_class = ActiveRecord::Base.default_timezone == :utc ?
          PG::TextDecoder::TimestampUtc :
          PG::TextDecoder::TimestampWithoutTimeZone

        # Use keyword argument splat for pg 1.6+ compatibility (Ruby 2.7+)
        @timestamp_decoder = decoder_class.new(**@timestamp_decoder.to_h)
        @connection.type_map_for_results.add_coder(@timestamp_decoder)
        @default_timezone = ActiveRecord::Base.default_timezone
      end
    end
  end
end
