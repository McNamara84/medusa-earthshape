require 'spec_helper'

RSpec.describe "No Factory Test", type: :controller do
  controller(ApplicationController) do
    def index
      render plain: "ok"
    end
  end
  
  describe "test with let" do
    let(:user) do
      puts "Creating user in let..."
      User.create!(
        username: "testuser_let",
        email: "test_let@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end
    
    it "uses user from let" do
      puts "Test starting..."
      puts "User from let: #{user.id}"
      expect(user).to be_persisted
      puts "Test completed!"
    end
  end
  
  describe "test with before" do
    before do
      puts "Creating user in before..."
      @user = User.create!(
        username: "testuser_before",
        email: "test_before@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
      puts "User created in before: #{@user.id}"
    end
    
    it "uses user from before" do
      puts "Test starting with @user..."
      expect(@user).to be_persisted
      puts "Test completed!"
    end
  end
end
