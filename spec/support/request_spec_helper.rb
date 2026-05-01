module RequestSpecHelper
  def login(user)
    login_as(user, scope: :user)

    User.current = user
  end
end
