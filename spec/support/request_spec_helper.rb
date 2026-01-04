module RequestSpecHelper
  def login(user)
    Warden.test_mode!
    login_as(user, scope: :user)

    # Warden test helpers authenticate through the Rack middleware, so the user is
    # available in request context. User.current is set for code paths that rely on
    # thread-local access outside the request cycle.
    User.current = user
  end
end
