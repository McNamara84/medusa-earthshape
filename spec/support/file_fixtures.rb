# Rails 6.1: Configure file_fixture_path for fixture_file_upload support
# Monkey-patch the RailsFixtureFileWrapper to provide file_fixture_path
module RSpec
  module Rails
    module FixtureFileUploadSupport
      class RailsFixtureFileWrapper
        def self.file_fixture_path
          ::Rails.root.join('spec', 'fixtures', 'files')
        end
      end
    end
  end
end
