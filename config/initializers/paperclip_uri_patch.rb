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
# ## Security Considerations
#
# This patch preserves URI reserved characters (?, &, =, etc.) because Paperclip
# generates complete URL paths that may include query strings. However, this means
# filenames containing these characters will NOT be encoded.
#
# **IMPORTANT**: Filename sanitization must be performed BEFORE URL generation.
# Paperclip's default configuration includes filename sanitization via:
# - Paperclip::Attachment validates filenames
# - The :restricted_characters option (default removes special chars)
#
# If you allow user-uploaded filenames, ensure Paperclip's filename processing
# is enabled, or add custom sanitization in your model's before_save callback.
#
# This patch should be removed when migrating to ActiveStorage.

require 'cgi'

module URI
  # Pattern for characters that should be percent-encoded in URIs.
  #
  # This pattern is specifically designed for Paperclip's URL generation needs,
  # which primarily handles file paths. It preserves URI reserved characters
  # (RFC 3986) that are commonly used in URLs.
  #
  # Characters preserved (not escaped):
  # - Alphanumeric: A-Z a-z 0-9
  # - Unreserved: - . _ ~
  # - Reserved (gen-delims): : / ? # [ ] @
  # - Reserved (sub-delims): ! $ & ' ( ) * + , ; =
  #
  # **Security Note**: Reserved characters like ?, &, = are preserved because
  # Paperclip may generate URLs with query strings (e.g., for S3 signed URLs).
  # Filename sanitization should be handled by Paperclip's attachment processing
  # or application-level validation before filenames reach URL generation.
  UNSAFE_PATTERN = /[^A-Za-z0-9\-._~:\/?#\[\]@!$&'()*+,;=]/

  # Pattern to match percent-encoded sequences (%XX where XX are hex digits)
  # Used to identify already-encoded portions of a string to prevent double-encoding.
  PERCENT_ENCODED_PATTERN = /%[0-9A-Fa-f]{2}/

  # Pre-compiled pattern for splitting strings by encoded sequences.
  # Cached as a constant to avoid repeated regex compilation on each call.
  # The capturing group ensures split() includes the matched sequences in results.
  SPLIT_BY_ENCODED_PATTERN = /(#{PERCENT_ENCODED_PATTERN})/

  class << self
    # Provide URI.escape for Ruby 3.0+ compatibility.
    #
    # This implementation uses a segment-based approach to handle partially
    # encoded URLs correctly:
    #
    # 1. Split the string by already-encoded sequences (%XX)
    #    Example: "/file%20name here.jpg" => ["/file", "%20", "name here.jpg"]
    #
    # 2. For each segment, check if it's an encoded sequence (matches %XX exactly)
    #    - If yes: preserve as-is (already encoded)
    #    - If no: encode any unsafe characters in this plain-text segment
    #
    # 3. Rejoin all segments
    #
    # This approach correctly handles edge cases:
    # - "%2" splits to ["", "%2", ""] but "%2" doesn't match PERCENT_ENCODED_PATTERN
    #   (requires exactly 2 hex digits), so it gets encoded to "%252"
    # - "%GH" similarly doesn't match, so "%" becomes "%25"
    #
    # @param str [String] The string to escape
    # @param unsafe [Regexp] Pattern matching characters to escape (optional)
    # @return [String] The escaped string
    #
    # @example Basic encoding
    #   URI.escape("/path/to/file.jpg")       # => "/path/to/file.jpg"
    #   URI.escape("/path/with spaces.jpg")   # => "/path/with%20spaces.jpg"
    #
    # @example Already encoded URLs (no double-encoding)
    #   URI.escape("/already%20encoded.jpg")  # => "/already%20encoded.jpg"
    #
    # @example Partially encoded URLs (encode remaining unsafe chars)
    #   URI.escape("/file%20name here.jpg")   # => "/file%20name%20here.jpg"
    #
    # @example Multi-byte UTF-8 characters
    #   URI.escape("/Ümläut.jpg")             # => "/%C3%9Cml%C3%A4ut.jpg"
    #
    def escape(str, unsafe = UNSAFE_PATTERN)
      string = str.to_s
      return string if string.empty?

      # Split string into segments: alternating between encoded sequences and plain text
      # Using pre-compiled SPLIT_BY_ENCODED_PATTERN for performance
      segments = string.split(SPLIT_BY_ENCODED_PATTERN)

      segments.map do |segment|
        if segment.match?(PERCENT_ENCODED_PATTERN)
          # Already encoded sequence (exactly %XX) - preserve as-is
          segment
        else
          # Plain text segment (may include incomplete sequences like "%2" or "%GH")
          # These will have their "%" encoded to "%25"
          encode_segment(segment, unsafe)
        end
      end.join
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

    private

    # Encode unsafe characters in a string segment.
    #
    # @param segment [String] The segment to encode
    # @param unsafe [Regexp] Pattern matching characters to escape
    # @return [String] The encoded segment
    #
    def encode_segment(segment, unsafe)
      segment.gsub(unsafe) do |char|
        '%' + char.unpack('H2' * char.bytesize).join('%').upcase
      end
    end
  end
end
