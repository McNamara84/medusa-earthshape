class SystemLabPreferencesController < ApplicationController
  authorize_resource :class => false
  layout "admin_lab"

  def show
  end

end
