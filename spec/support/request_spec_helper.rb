module RequestSpecHelper
  def login(user)
    Warden.test_mode!
    login_as(user, scope: :user)

    # Warden test_mode simulates authentication for request specs by setting the
    # user in the test session/env; it does not exercise the real login flow.
    # User.current is set for code paths that rely on thread-local access.
    User.current = user
  end
end
