require 'spec_helper'

RSpec.describe "Factory in Model Spec", type: :model do
  it "builds user with FactoryBot in model context" do
    puts "Starting model test with FactoryBot.build..."
    
    user = FactoryBot.build(:user)
    
    puts "User built via FactoryBot: #{user.username}"
    expect(user).to be_valid
    puts "Model test completed!"
  end
  
  it "creates user with FactoryBot in model context" do
    puts "Starting model test with FactoryBot.create..."
    
    user = FactoryBot.create(:user)
    
    puts "User created via FactoryBot: #{user.id}"
    expect(user).to be_persisted
    puts "Model test completed!"
  end
end
