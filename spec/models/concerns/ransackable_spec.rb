require "spec_helper"

describe Ransackable do
  describe ".ransackable_attributes" do
    it "excludes sensitive authentication fields on user" do
      expect(User.ransackable_attributes).to include("username", "administrator")
      expect(User.ransackable_attributes).not_to include("encrypted_password")
      expect(User.ransackable_attributes).not_to include("authentication_token")
    end

    it "includes regular model columns for domain models" do
      expect(Stone.ransackable_attributes).to include("name", "collection_id", "box_id")
    end
  end

  describe ".ransackable_associations" do
    it "returns searchable associations for user" do
      expect(User.ransackable_associations).to include("groups", "box", "record_properties")
    end

    it "returns searchable associations for stone" do
      expect(Stone.ransackable_associations).to include("box", "place", "collection", "analyses")
    end
  end
end