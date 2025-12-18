# frozen_string_literal: true

# Shared concern for models that support CSV import functionality.
# Provides a common list of permitted MIME types for CSV file uploads.
#
# Usage:
#   class MyModel < ApplicationRecord
#     include CsvImportable
#
#     def self.import_csv(file)
#       return unless csv_file_valid?(file)
#       # ... import logic
#     end
#   end
#
module CsvImportable
  extend ActiveSupport::Concern

  # Extended list of CSV MIME types to handle browser/OS variations:
  # - text/plain: Plain text files (often used for CSV)
  # - text/csv: Standard CSV MIME type
  # - text/x-csv: Alternative CSV MIME type (some systems)
  # - text/comma-separated-values: Official IANA MIME type for CSV
  # - application/csv: Application-level CSV MIME type
  # - application/x-csv: Alternative application-level CSV
  # - application/vnd.ms-excel: Excel files (often CSV exported from Excel)
  # - application/octet-stream: Generic binary (browsers often use this for unknown types)
  PERMIT_IMPORT_TYPES = [
    "text/plain",
    "text/csv",
    "text/x-csv",
    "text/comma-separated-values",
    "application/csv",
    "application/x-csv",
    "application/vnd.ms-excel",
    "application/octet-stream"
  ].freeze

  class_methods do
    # Check if the uploaded file has a valid CSV content type
    #
    # @param file [ActionDispatch::Http::UploadedFile] The uploaded file
    # @return [Boolean] true if file is present and has valid content type
    def csv_file_valid?(file)
      file.present? && PERMIT_IMPORT_TYPES.include?(file.content_type)
    end
  end
end
