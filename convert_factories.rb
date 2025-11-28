#!/usr/bin/env ruby
# Script to convert FactoryGirl static attributes to FactoryBot block syntax

Dir.glob('spec/factories/*.rb').each do |file|
  content = File.read(file)
  original = content.dup

  # Match lines with static attributes: attribute_name "value" or 'value'
  # But skip keywords like association, sequence, factory, trait, parent
  content.gsub!(/^(\s+)(\w+)\s+("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')\s*$/) do |match|
    indent = $1
    attr = $2
    value = $3
    
    # Skip special keywords
    if %w[association sequence factory trait parent class].include?(attr)
      match
    else
      "#{indent}#{attr} { #{value} }"
    end
  end

  # Handle numeric values: attribute 123 or 1.5
  content.gsub!(/^(\s+)(\w+)\s+(\d+\.?\d*)\s*$/) do |match|
    indent = $1
    attr = $2
    value = $3
    
    if %w[association sequence factory trait parent class lft rgt position].include?(attr)
      match
    else
      "#{indent}#{attr} { #{value} }"
    end
  end

  # Handle true/false/nil values
  content.gsub!(/^(\s+)(\w+)\s+(true|false|nil)\s*$/) do |match|
    indent = $1
    attr = $2
    value = $3
    
    if %w[association sequence factory trait parent class].include?(attr)
      match
    else
      "#{indent}#{attr} { #{value} }"
    end
  end

  # Handle empty string: parent_id ""
  content.gsub!(/^(\s+)(\w+)\s+("")\s*$/) do |match|
    indent = $1
    attr = $2
    value = $3
    "#{indent}#{attr} { #{value} }"
  end

  # Handle array literals: affine_matrix [1,0,0,0,1,0,0,0,1]
  content.gsub!(/^(\s+)(\w+)\s+(\[[^\]]+\])\s*$/) do |match|
    indent = $1
    attr = $2
    value = $3
    "#{indent}#{attr} { #{value} }"
  end

  if content != original
    File.write(file, content)
    puts "Updated: #{file}"
  else
    puts "No changes: #{file}"
  end
end

puts "\nDone!"
