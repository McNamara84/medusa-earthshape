module RequestSpecHelper
  def login(user)
    Warden.test_mode!
    login_as(user, scope: :user)

    # Set User.current for use in test context (not in HTTP requests)
    User.current = user
  end
end
