require 'spec_helper'

# Asset Pipeline Precompilation Tests
# These tests verify that assets compile without errors in the test environment
describe "Asset Pipeline" do
  it "compiles application.css without errors" do
    # Force asset compilation
    asset = Rails.application.assets['application.css']
    expect(asset).not_to be_nil
    expect(asset.to_s).to include('css')  # Basic sanity check
  end
  
  it "compiles application.js without errors" do
    asset = Rails.application.assets['application.js']
    expect(asset).not_to be_nil
    expect(asset.to_s).to include('function')  # Basic sanity check - JS should contain functions
  end
  
  it "compiles adjustments.css.scss without Sass errors" do
    # This is the file that had the asset-url syntax error
    asset = Rails.application.assets['adjustments.css']
    expect(asset).not_to be_nil
  end
  
  it "loads CSV icon image asset" do
    # This specific asset caused the Template::Error in production
    asset = Rails.application.assets['csv.png']
    expect(asset).not_to be_nil
  end
end
