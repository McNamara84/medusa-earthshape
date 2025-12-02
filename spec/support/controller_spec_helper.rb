module ControllerSpecHelper
  # Devise helpers are now included via RSpec.configure in spec_helper.rb
  
  def sign_in(resource_or_scope, resource=nil)
    super
    User.current = resource || resource_or_scope
  end
end
