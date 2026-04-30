require "spec_helper"
require "securerandom"

describe HasIgsn do
  let(:unique_token) { SecureRandom.hex(4) }
  let(:user) do
    FactoryBot.create(
      :user,
      email: "igsn-#{unique_token}@example.com",
      username: "igsn_user_#{unique_token}",
      prefix: "GFABC"
    )
  end

  let(:stone) do
    User.current = user
    FactoryBot.create(:stone, box: FactoryBot.create(:box, name: "has-igsn-box-#{unique_token}"))
  end

  let(:literals) do
    ("0".."9").to_a + ("A".."Z").to_a - ["I", "O"]
  end

  let(:literal_to_number) do
    literals.each_with_index.to_h
  end

  let(:number_to_literal) do
    literals.each_with_index.map { |literal, index| [index, literal] }.to_h
  end

  after do
    User.current = nil
  end

  describe "#to_number" do
    it "converts an IGSN suffix into its numeric representation" do
      expect(stone.to_number("10", literal_to_number)).to eq 34
      expect(stone.to_number("A", literal_to_number)).to eq 10
      expect(stone.to_number("Z", literal_to_number)).to eq 33
    end
  end

  describe "#to_igsn" do
    it "converts a numeric sequence into an IGSN suffix" do
      expect(stone.to_igsn(34, number_to_literal)).to eq "10"
      expect(stone.to_igsn(33, number_to_literal)).to eq "Z"
      expect(stone.to_igsn(1, number_to_literal)).to eq "1"
    end
  end

  describe "#create_igsn" do
    it "uses the provided prefix when present" do
      stone.create_igsn("GFZZZ", stone)

      expect(stone.igsn).to eq "GFZZZ0000"
    end

    it "falls back to the owner's prefix when no prefix is passed" do
      stone.create_igsn(nil, stone)

      expect(stone.igsn).to eq "GFABC0000"
    end

    it "increments from the latest matching IGSN" do
      User.current = user
      FactoryBot.create(:stone, igsn: "GFABC0000", box: FactoryBot.create(:box, name: "has-igsn-existing-box-#{unique_token}"))

      stone.create_igsn(nil, stone)

      expect(stone.igsn).to eq "GFABC0001"
    end

    it "raises a clear error before querying when no prefix is available" do
      user.update!(prefix: nil)

      expect(Stone).not_to receive(:where)

      expect {
        stone.create_igsn(nil, stone)
      }.to raise_error(ArgumentError, "IGSN prefix is required")
    end
  end
end