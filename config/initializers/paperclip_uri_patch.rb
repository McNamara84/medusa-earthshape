# frozen_string_literal: true

# Ruby 3.0 Compatibility Patch for Paperclip
#
# URI.escape was deprecated in Ruby 2.7 and removed in Ruby 3.0.
# Paperclip 6.1.0 still uses URI.escape in lib/paperclip/url_generator.rb:68
# This patch provides a compatible replacement.
#
# See: https://github.com/thoughtbot/paperclip/issues/2752
# Note: Paperclip is deprecated since 2018. Migration to ActiveStorage is recommended.
#
# This patch should be removed when migrating to ActiveStorage.

require 'cgi'

module URI
  # Default unsafe characters that URI.escape used to escape
  # This matches the original Ruby behavior for URI.escape
  UNSAFE_PATTERN = /[^A-Za-z0-9\-._~:\/?#\[\]@!$&'()*+,;=]/

  class << self
    # Provide URI.escape for Ruby 3.0+ compatibility
    # Preserves slashes and other path-safe characters, only escaping truly unsafe chars
    def escape(str, unsafe = UNSAFE_PATTERN)
      str.to_s.gsub(unsafe) do |char|
        '%' + char.unpack('H2' * char.bytesize).join('%').upcase
      end
    end

    # Also provide URI.unescape for completeness
    def unescape(str, _unsafe = nil)
      CGI.unescape(str.to_s)
    end
  end
end
