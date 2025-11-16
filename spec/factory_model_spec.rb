require 'spec_helper'

RSpec.describe "Factory in Model Spec", type: :model do
  it "builds user with FactoryGirl in model context" do
    puts "Starting model test with FactoryGirl.build..."
    
    user = FactoryGirl.build(:user)
    
    puts "User built via FactoryGirl: #{user.username}"
    expect(user).to be_valid
    puts "Model test completed!"
  end
  
  it "creates user with FactoryGirl in model context" do
    puts "Starting model test with FactoryGirl.create..."
    
    user = FactoryGirl.create(:user)
    
    puts "User created via FactoryGirl: #{user.id}"
    expect(user).to be_persisted
    puts "Model test completed!"
  end
end
