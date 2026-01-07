# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("config/support/env")

RSpec.describe MedusaEnv do
  describe ".truthy?" do
    it "treats whitespace-only strings as false" do
      expect(described_class.truthy?("   ")).to be(false)
    end
  end
end
