require "spec_helper"

RSpec.describe "ActionController::Parameters#only_presence" do
  it "filters blank values recursively" do
    params = ActionController::Parameters.new(
      "a" => "",
      "b" => { "c" => "", "d" => "x" },
      "e" => [{ "f" => "" }, { "f" => "y" }, {}],
      "g" => [],
      "h" => nil
    )

    filtered = params.only_presence

    expect(filtered.to_unsafe_h).to eq(
      "b" => { "d" => "x" },
      "e" => [{ "f" => "y" }]
    )
  end

  it "preserves permittedness" do
    params = ActionController::Parameters.new(
      "a" => "",
      "b" => { "c" => "x" }
    ).permit!

    filtered = params.only_presence

    expect(filtered).to be_permitted
    expect(filtered.to_h).to eq("b" => { "c" => "x" })
  end
end
