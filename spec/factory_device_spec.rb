require 'spec_helper'

RSpec.describe "Factory Device Test" do
  it "creates device via FactoryBot (no Devise)" do
    puts "Creating device..."
    device = FactoryBot.create(:device)
    puts "Device created: #{device.id}"
    expect(device).to be_persisted
  end
end
