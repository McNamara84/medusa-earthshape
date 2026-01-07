# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("config/support/env")

RSpec.describe MedusaEnv do
  describe ".truthy?" do
    it "treats nil as false" do
      expect(described_class.truthy?(nil)).to be(false)
    end

    it "treats empty strings as false" do
      expect(described_class.truthy?("")).to be(false)
    end

    it "treats whitespace-only strings as false" do
      expect(described_class.truthy?("   ")).to be(false)
    end

    it "treats '0' as false" do
      expect(described_class.truthy?("0")).to be(false)
    end

    it "treats 'false' (case-insensitive) as false" do
      expect(described_class.truthy?("false")).to be(false)
      expect(described_class.truthy?("FALSE")).to be(false)
      expect(described_class.truthy?("  False  ")).to be(false)
    end

    it "treats 'true' as true" do
      expect(described_class.truthy?("true")).to be(true)
      expect(described_class.truthy?(" TRUE ")).to be(true)
    end

    it "treats '1' as true" do
      expect(described_class.truthy?("1")).to be(true)
    end

    it "treats other non-empty strings as true" do
      expect(described_class.truthy?("yes")).to be(true)
      expect(described_class.truthy?("on")).to be(true)
    end
  end
end
