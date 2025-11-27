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
  # Pattern for characters that should be percent-encoded in URIs.
  #
  # This pattern is specifically designed for Paperclip's URL generation needs,
  # which primarily handles file paths. It preserves URI reserved characters
  # (RFC 3986) that are commonly used in URLs: : / ? # [ ] @ ! $ & ' ( ) * + , ; =
  #
  # Note: This differs from Ruby's original URI.escape which used a more
  # restrictive pattern based on URI::PATTERN::UNRESERVED. This implementation
  # preserves more characters to avoid breaking valid URL paths that Paperclip
  # generates (e.g., /system/attachment_files/0000/1234/file.jpg).
  #
  # Characters preserved (not escaped):
  # - Alphanumeric: A-Z a-z 0-9
  # - Unreserved: - . _ ~
  # - Reserved (gen-delims): : / ? # [ ] @
  # - Reserved (sub-delims): ! $ & ' ( ) * + , ; =
  UNSAFE_PATTERN = /[^A-Za-z0-9\-._~:\/?#\[\]@!$&'()*+,;=]/

  # Pattern to detect already percent-encoded sequences (%XX)
  PERCENT_ENCODED = /%[0-9A-Fa-f]{2}/

  class << self
    # Provide URI.escape for Ruby 3.0+ compatibility.
    #
    # This implementation includes protection against double-encoding:
    # strings that are already percent-encoded will not be re-encoded.
    #
    # @param str [String] The string to escape
    # @param unsafe [Regexp] Pattern matching characters to escape (optional)
    #   Note: Custom patterns are supported but the default UNSAFE_PATTERN
    #   is optimized for Paperclip's URL generation needs.
    # @return [String] The escaped string
    #
    # @example
    #   URI.escape("/path/to/file.jpg")       # => "/path/to/file.jpg"
    #   URI.escape("/path/with spaces.jpg")   # => "/path/with%20spaces.jpg"
    #   URI.escape("/already%20encoded.jpg")  # => "/already%20encoded.jpg" (no double-encoding)
    #
    def escape(str, unsafe = UNSAFE_PATTERN)
      string = str.to_s
      
      # Check if string appears to be already encoded (contains %XX patterns)
      # If so, return as-is to prevent double-encoding
      return string if string.match?(PERCENT_ENCODED)
      
      string.gsub(unsafe) do |char|
        '%' + char.unpack('H2' * char.bytesize).join('%').upcase
      end
    end

    # Provide URI.unescape for Ruby 3.0+ compatibility.
    #
    # @param str [String] The string to unescape
    # @param _unsafe [Regexp] Unused, kept for API compatibility
    # @return [String] The unescaped string
    #
    def unescape(str, _unsafe = nil)
      CGI.unescape(str.to_s)
    end
  end
end
