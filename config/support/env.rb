# frozen_string_literal: true

module MedusaEnv
  FALSEY = %w[0 false].freeze

  def self.truthy?(value)
    return false if value.nil?

    normalized = value.to_s.strip.downcase
    return false if normalized.empty?

    !FALSEY.include?(normalized)
  end
end
