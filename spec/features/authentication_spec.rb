require 'spec_helper'

feature "User authentication" do
  let(:user) { FactoryGirl.create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  
  before do
    user  # Create user before tests
  end

  scenario "User signs in with valid credentials" do
    visit new_user_session_path
    
    # Check login form is rendered
    expect(page).to have_content('Sign in')
    expect(page).to have_field('Email')
    expect(page).to have_field('Password')
    
    # Fill in and submit form
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password123'
    click_button 'Sign in'
    
    # Verify successful login
    expect(page).to have_content('Signed in successfully')
    expect(current_path).to eq(root_path)
  end

  scenario "User fails to sign in with invalid credentials" do
    visit new_user_session_path
    
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'wrongpassword'
    click_button 'Sign in'
    
    # Verify error message
    expect(page).to have_content('Invalid Email or password')
    expect(current_path).to eq(new_user_session_path)
  end

  scenario "User signs out" do
    # Login first
    visit new_user_session_path
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password123'
    click_button 'Sign in'
    
    # Sign out
    click_link 'Sign out'
    
    # Verify signed out
    expect(page).to have_content('Signed out successfully')
    expect(current_path).to eq(root_path)
  end
end
