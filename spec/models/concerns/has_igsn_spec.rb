require "spec_helper"

describe HasIgsn do
  let(:user) do
    FactoryBot.create(
      :user,
      email: "igsn@example.com",
      username: "igsn_user",
      prefix: "GFABC"
    )
  end

  let(:stone) do
    User.current = user
    FactoryBot.create(:stone)
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
    it "assigns the first sequence using the owner's prefix" do
      stone.create_igsn("IGNORED", stone)

      expect(stone.igsn).to eq "GFABC0000"
    end

    it "increments from the latest matching IGSN" do
      User.current = user
      FactoryBot.create(:stone, igsn: "GFABC0000")

      stone.create_igsn("OTHER", stone)

      expect(stone.igsn).to eq "GFABC0001"
    end
  end
end