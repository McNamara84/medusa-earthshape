#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to migrate Glyphicons to Bootstrap Icons in ERB views
# Run from Rails root: ruby scripts/migrate_glyphicons_to_bi.rb
#
# This script handles:
# 1. <span class="glyphicon glyphicon-X"></span> → <%= bi_icon('X') %>
# 2. <i class="glyphicon glyphicon-X"></i> → <%= bi_icon('X') %>
# 3. content_tag(:span, nil, class: "glyphicon glyphicon-X") → bi_icon('X')
# 4. Self-closing tags: <span class="glyphicon glyphicon-X"/>

require 'fileutils'

# Find all ERB files in app/views
view_files = Dir.glob('app/views/**/*.erb')

puts "Found #{view_files.count} ERB files to scan"

# Counters
total_replacements = 0
files_modified = 0

view_files.each do |file_path|
  content = File.read(file_path)
  original_content = content.dup
  file_replacements = 0
  
  # Pattern 1: <span class="glyphicon glyphicon-ICON"></span>
  # Convert to: <%= bi_icon('ICON') %>
  content.gsub!(/<span\s+class=["']glyphicon\s+glyphicon-([a-z0-9-]+)["']><\/span>/i) do
    icon_name = $1
    file_replacements += 1
    "<%= bi_icon('#{icon_name}') %>"
  end
  
  # Pattern 2: <span class="glyphicon glyphicon-ICON"/> (self-closing)
  # Convert to: <%= bi_icon('ICON') %>
  content.gsub!(/<span\s+class=["']glyphicon\s+glyphicon-([a-z0-9-]+)["']\s*\/>/i) do
    icon_name = $1
    file_replacements += 1
    "<%= bi_icon('#{icon_name}') %>"
  end
  
  # Pattern 3: <i class="glyphicon glyphicon-ICON"></i>
  # Convert to: <%= bi_icon('ICON') %>
  content.gsub!(/<i\s+class=["']glyphicon\s+glyphicon-([a-z0-9-]+)["']><\/i>/i) do
    icon_name = $1
    file_replacements += 1
    "<%= bi_icon('#{icon_name}') %>"
  end
  
  # Pattern 4: content_tag(:span, nil, class: "glyphicon glyphicon-ICON")
  # Convert to: bi_icon('ICON')
  content.gsub!(/content_tag\(:span,\s*nil,\s*class:\s*["']glyphicon\s+glyphicon-([a-z0-9-]+)["']\)/i) do
    icon_name = $1
    file_replacements += 1
    "bi_icon('#{icon_name}')"
  end
  
  # Pattern 5: content_tag(:span, "", class: "glyphicon glyphicon-ICON")
  # Convert to: bi_icon('ICON')
  content.gsub!(/content_tag\(:span,\s*"",\s*class:\s*["']glyphicon\s+glyphicon-([a-z0-9-]+)["']\)/i) do
    icon_name = $1
    file_replacements += 1
    "bi_icon('#{icon_name}')"
  end
  
  # Write back if changes were made
  if content != original_content
    File.write(file_path, content)
    files_modified += 1
    total_replacements += file_replacements
    puts "✓ #{file_path}: #{file_replacements} replacement(s)"
  end
end

puts "\n" + "=" * 50
puts "Migration complete!"
puts "Files modified: #{files_modified}"
puts "Total replacements: #{total_replacements}"
puts "=" * 50

# Check for remaining glyphicons
puts "\nChecking for remaining glyphicon references..."
remaining = `grep -r "glyphicon" app/views --include="*.erb" 2>/dev/null | wc -l`.strip
puts "Remaining glyphicon references: #{remaining}"

if remaining.to_i > 0
  puts "\nRemaining patterns (may need manual review):"
  system('grep -r "glyphicon" app/views --include="*.erb" | head -20')
end
