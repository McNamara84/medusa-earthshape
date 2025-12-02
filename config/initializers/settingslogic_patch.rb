# Patch for Settingslogic to work with Ruby 3.1+ (Psych 4)
# Settingslogic 2.0.9 has issues with namespace loading in newer Ruby versions
# This patch overrides the hash loading to properly apply the namespace

require 'settingslogic'

module SettingslogicPatch
  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
  
  module ClassMethods
    def hash_from_file
      hash = YAML.load(ERB.new(File.read(source)).result, permitted_classes: [Symbol], aliases: true)
      hash = hash[namespace] if namespace && hash.key?(namespace)
      hash || {}
    end
    
    private
    
    def instance
      return @instance if @instance
      @instance = new(hash_from_file)
      create_accessors!
      @instance
    end
  end
end

Settingslogic.prepend(SettingslogicPatch)
