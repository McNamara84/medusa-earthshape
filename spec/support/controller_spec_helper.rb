module ControllerSpecHelper
  # Devise helpers are now included via RSpec.configure in spec_helper.rb
  
  def sign_in(resource_or_scope, resource=nil)
    # Rails 8.0: Ensure @request is initialized with proper env before calling Devise sign_in
    # The Devise::Test::ControllerHelpers#sign_in method accesses @request.env['warden']
    # which requires @request to be set up first
    unless @request
      @request = ActionController::TestRequest.create(self.class.controller_class)
    end
    
    # Rails 8.0: Ensure warden is set up in the request environment
    warden = @request.env['warden']
    unless warden
      @request.env['warden'] = Warden::Proxy.new(@request.env, Warden::Manager.new(nil))
    end
    
    super
    User.current = resource || resource_or_scope
  end
end
