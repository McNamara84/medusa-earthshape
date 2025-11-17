module RequestSpecHelper
  # Rails 5.0: Use real form submission for request specs instead of Warden
  # Warden.test_mode doesn't work with Poltergeist/PhantomJS (separate process)
  
  def login(user)
    visit new_user_session_path
    fill_in 'user_username', with: user.username
    fill_in 'user_password', with: user.password
    click_button 'Sign in'
    
    # Verify login succeeded
    if current_path == new_user_session_path
      raise "Login failed for user #{user.username}"
    end
    
    # Set User.current for use in test context (not in HTTP requests)
    User.current = user
  end
end
