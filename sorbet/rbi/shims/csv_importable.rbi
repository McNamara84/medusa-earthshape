# typed: true

# Sorbet type signature for CsvImportable concern
module CsvImportable
  extend ActiveSupport::Concern

  PERMIT_IMPORT_TYPES = T.let([
    "text/plain",
    "text/csv",
    "text/x-csv",
    "text/comma-separated-values",
    "application/csv",
    "application/x-csv",
    "application/vnd.ms-excel",
    "application/octet-stream"
  ].freeze, T::Array[String])

  module ClassMethods
    sig { params(file: T.untyped).returns(T::Boolean) }
    def csv_file_valid?(file); end
  end
end
