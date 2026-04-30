require "spec_helper"

describe GlobalQr do
  it "belongs to a record property" do
    reflection = described_class.reflect_on_association(:record_property)

    expect(reflection.macro).to eq(:belongs_to)
  end
end