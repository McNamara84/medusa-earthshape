require "spec_helper"

describe "URI.escape patch for Ruby 3.0+ compatibility" do
  describe "URI.escape" do
    context "with simple paths (no special characters)" do
      it "returns path unchanged" do
        expect(URI.escape("/path/to/file.jpg")).to eq("/path/to/file.jpg")
      end

      it "preserves alphanumeric characters" do
        expect(URI.escape("/abc123/XYZ789.txt")).to eq("/abc123/XYZ789.txt")
      end

      it "preserves unreserved characters (RFC 3986)" do
        expect(URI.escape("/path-name/file_name.test~backup")).to eq("/path-name/file_name.test~backup")
      end

      it "preserves reserved characters used in URLs" do
        expect(URI.escape("/path?query=value&other=1#anchor")).to eq("/path?query=value&other=1#anchor")
      end
    end

    context "with spaces" do
      it "encodes spaces as %20" do
        expect(URI.escape("/path/with spaces.jpg")).to eq("/path/with%20spaces.jpg")
      end

      it "encodes multiple spaces" do
        expect(URI.escape("/my file name.jpg")).to eq("/my%20file%20name.jpg")
      end

      it "encodes spaces at beginning and end" do
        expect(URI.escape(" leading and trailing ")).to eq("%20leading%20and%20trailing%20")
      end
    end

    context "with special characters requiring encoding" do
      it "encodes less-than and greater-than" do
        expect(URI.escape("/file<name>.jpg")).to eq("/file%3Cname%3E.jpg")
      end

      it "encodes double quotes" do
        expect(URI.escape('/file"name".jpg')).to eq("/file%22name%22.jpg")
      end

      it "encodes backslash" do
        expect(URI.escape("/path\\file.jpg")).to eq("/path%5Cfile.jpg")
      end

      it "encodes pipe character" do
        expect(URI.escape("/file|name.jpg")).to eq("/file%7Cname.jpg")
      end

      it "encodes caret" do
        expect(URI.escape("/file^name.jpg")).to eq("/file%5Ename.jpg")
      end

      it "encodes backtick" do
        expect(URI.escape("/file`name.jpg")).to eq("/file%60name.jpg")
      end

      it "encodes curly braces" do
        expect(URI.escape("/file{name}.jpg")).to eq("/file%7Bname%7D.jpg")
      end

      it "encodes percent sign" do
        expect(URI.escape("/file%name.jpg")).to eq("/file%25name.jpg")
      end
    end

    context "with already percent-encoded URLs (no double-encoding)" do
      it "preserves already encoded space (%20)" do
        expect(URI.escape("/already%20encoded.jpg")).to eq("/already%20encoded.jpg")
      end

      it "preserves multiple encoded sequences" do
        expect(URI.escape("/file%20name%3Cwith%3Eencoding.jpg")).to eq("/file%20name%3Cwith%3Eencoding.jpg")
      end

      # Note: %2f (lowercase) and %2F (uppercase) are both valid percent-encoded
      # representations of the forward slash character '/'. When these appear in
      # an input string, they are preserved as-is because:
      # 1. They match the PERCENT_ENCODED_PATTERN (%XX where XX are hex digits)
      # 2. Double-encoding would turn %2f into %252f, breaking the URL
      #
      # This is intentional: if the input contains %2f, we assume it was already
      # encoded by a previous operation and should not be modified.
      it "preserves lowercase hex digits in encoded sequences" do
        expect(URI.escape("/file%2fname.jpg")).to eq("/file%2fname.jpg")
      end

      it "preserves uppercase hex digits in encoded sequences" do
        expect(URI.escape("/file%2Fname.jpg")).to eq("/file%2Fname.jpg")
      end
    end

    context "with partially encoded URLs (the key fix)" do
      it "encodes remaining spaces while preserving encoded ones" do
        expect(URI.escape("/file%20name here.jpg")).to eq("/file%20name%20here.jpg")
      end

      it "encodes unencoded special chars while preserving encoded ones" do
        expect(URI.escape("/path%20with spaces and%3Cangles>.jpg")).to eq("/path%20with%20spaces%20and%3Cangles%3E.jpg")
      end

      it "handles complex mixed encoding" do
        input = "/system%20files/attachment%20name <test>.jpg"
        expected = "/system%20files/attachment%20name%20%3Ctest%3E.jpg"
        expect(URI.escape(input)).to eq(expected)
      end

      it "handles encoded sequences scattered throughout" do
        input = "a%20b c%20d e"
        expected = "a%20b%20c%20d%20e"
        expect(URI.escape(input)).to eq(expected)
      end
    end

    context "with multi-byte UTF-8 characters" do
      it "encodes German umlauts" do
        expect(URI.escape("/Ümläut.jpg")).to eq("/%C3%9Cml%C3%A4ut.jpg")
      end

      it "encodes Japanese characters" do
        expect(URI.escape("/日本語.jpg")).to eq("/%E6%97%A5%E6%9C%AC%E8%AA%9E.jpg")
      end

      it "encodes Chinese characters" do
        expect(URI.escape("/中文.jpg")).to eq("/%E4%B8%AD%E6%96%87.jpg")
      end

      it "encodes emoji" do
        expect(URI.escape("/file📄.jpg")).to eq("/file%F0%9F%93%84.jpg")
      end

      it "handles mixed ASCII and UTF-8" do
        expect(URI.escape("/path/tëst fïlé.jpg")).to eq("/path/t%C3%ABst%20f%C3%AFl%C3%A9.jpg")
      end
    end

    context "with Paperclip-style paths" do
      it "handles standard Paperclip attachment path" do
        path = "/system/attachment_files/0000/1234/test_image.jpg"
        expect(URI.escape(path)).to eq(path)
      end

      it "handles Paperclip path with spaces in filename" do
        path = "/system/attachment_files/0000/1234/test image.jpg"
        expect(URI.escape(path)).to eq("/system/attachment_files/0000/1234/test%20image.jpg")
      end

      it "handles Paperclip path with special characters" do
        path = "/system/attachment_files/0000/1234/test(1).jpg"
        expect(URI.escape(path)).to eq(path) # parentheses are preserved
      end

      it "handles Paperclip path with parentheses and spaces" do
        path = "/system/attachment_files/0000/1234/test (1).jpg"
        expect(URI.escape(path)).to eq("/system/attachment_files/0000/1234/test%20(1).jpg")
      end

      it "handles deeply nested Paperclip paths" do
        path = "/system/attachment_files/1234/5678/original/test.jpg"
        expect(URI.escape(path)).to eq(path)
      end
    end

    context "with edge cases" do
      it "handles empty string" do
        expect(URI.escape("")).to eq("")
      end

      it "handles nil (converts to string)" do
        expect(URI.escape(nil)).to eq("")
      end

      it "handles numeric input" do
        expect(URI.escape(12345)).to eq("12345")
      end

      it "handles string with only spaces" do
        expect(URI.escape("   ")).to eq("%20%20%20")
      end

      # Edge case: "%" not followed by two hex digits is NOT a valid percent-encoded
      # sequence. The split pattern /%[0-9A-Fa-f]{2}/ won't match "%n", so it remains
      # in a plain-text segment where "%" gets encoded to "%25".
      it "handles percent sign not followed by hex digits" do
        expect(URI.escape("/file%name.jpg")).to eq("/file%25name.jpg")
      end

      # Edge case: "%2" has only one hex digit, not two. This doesn't match the
      # PERCENT_ENCODED_PATTERN which requires exactly "%XX". The segment "%2"
      # is treated as plain text, encoding "%" to "%25".
      it "handles percent sign followed by only one hex digit" do
        expect(URI.escape("/file%2.jpg")).to eq("/file%252.jpg")
      end

      # Edge case: "%GH" has letters outside hex range (valid: 0-9, A-F, a-f).
      # "G" and "H" are not valid hex digits, so this doesn't match the pattern.
      it "handles percent sign followed by non-hex characters" do
        expect(URI.escape("/file%GH.jpg")).to eq("/file%25GH.jpg")
      end

      it "handles very long paths" do
        long_path = "/system/" + "path/" * 100 + "file.jpg"
        expect(URI.escape(long_path)).to eq(long_path)
      end
    end

    context "with custom unsafe pattern" do
      it "accepts custom pattern parameter" do
        # Custom pattern that also encodes forward slashes
        custom = /[^A-Za-z0-9\-._~]/
        expect(URI.escape("/path/to/file.jpg", custom)).to eq("%2Fpath%2Fto%2Ffile.jpg")
      end
    end

    # Security-related tests
    #
    # IMPORTANT: This URI.escape patch preserves reserved URI characters (?, &, =, etc.)
    # because Paperclip generates complete URLs that may include query strings.
    # Filename sanitization is the responsibility of Paperclip's attachment processing
    # or application-level validation BEFORE filenames reach URL generation.
    #
    # These tests document the expected behavior and security boundaries.
    context "with security considerations (reserved characters in paths)" do
      # This test documents that reserved characters are NOT encoded.
      # Filename sanitization must happen before URL generation.
      it "preserves query-like characters (security: relies on filename sanitization)" do
        # A malicious filename like "file.jpg?inject=value" keeps ? and = unencoded
        # Paperclip should sanitize filenames before they reach this point
        path = "/system/files/file.jpg?query=value"
        expect(URI.escape(path)).to eq(path)
      end

      it "preserves ampersand in paths (security: relies on filename sanitization)" do
        path = "/system/files/file&name.jpg"
        expect(URI.escape(path)).to eq(path)
      end

      # Path traversal sequences like "../" are preserved because "/" is a reserved
      # character. Prevention of path traversal attacks is handled at the filesystem
      # level by Paperclip's storage backend, not at URL encoding time.
      it "preserves path traversal sequences (security: handled by storage backend)" do
        path = "/system/files/../../../etc/passwd"
        # Forward slashes and dots are preserved (reserved/unreserved chars)
        expect(URI.escape(path)).to eq(path)
      end

      it "encodes null bytes (security: null byte injection prevention)" do
        # Null bytes should be encoded to prevent null byte injection attacks
        path = "/system/files/file\x00.jpg"
        expect(URI.escape(path)).to eq("/system/files/file%00.jpg")
      end

      it "encodes backslash (security: Windows path injection prevention)" do
        # Backslashes are encoded to prevent Windows-style path manipulation
        path = "/system/files/..\\..\\etc\\passwd"
        expect(URI.escape(path)).to eq("/system/files/..%5C..%5Cetc%5Cpasswd")
      end
    end
  end

  describe "URI.unescape" do
    it "decodes percent-encoded spaces" do
      expect(URI.unescape("/path%20with%20spaces.jpg")).to eq("/path with spaces.jpg")
    end

    it "decodes special characters" do
      expect(URI.unescape("/file%3Cname%3E.jpg")).to eq("/file<name>.jpg")
    end

    it "decodes UTF-8 characters" do
      expect(URI.unescape("/%C3%9Cml%C3%A4ut.jpg")).to eq("/Ümläut.jpg")
    end

    it "handles already decoded strings" do
      expect(URI.unescape("/path/to/file.jpg")).to eq("/path/to/file.jpg")
    end

    it "handles empty string" do
      expect(URI.unescape("")).to eq("")
    end

    it "handles nil" do
      expect(URI.unescape(nil)).to eq("")
    end

    it "is inverse of escape for simple cases" do
      original = "/path with spaces.jpg"
      expect(URI.unescape(URI.escape(original))).to eq(original)
    end

    it "is inverse of escape for UTF-8" do
      original = "/tëst fïlé.jpg"
      expect(URI.unescape(URI.escape(original))).to eq(original)
    end
  end

  describe "round-trip encoding" do
    it "preserves data through encode-decode cycle" do
      test_strings = [
        "/simple/path.jpg",
        "/path with spaces.jpg",
        "/path/with<special>chars.jpg",
        "/Ümläut/日本語/中文.jpg",
        "/mixed%20already encoded and spaces.jpg"
      ]

      test_strings.each do |original|
        # For partially encoded strings, decode first then re-encode
        decoded = URI.unescape(original)
        encoded = URI.escape(decoded)
        round_trip = URI.unescape(encoded)
        expect(round_trip).to eq(decoded), "Failed for: #{original}"
      end
    end
  end
end
