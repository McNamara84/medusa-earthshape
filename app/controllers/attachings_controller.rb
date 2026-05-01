class AttachingsController < ApplicationController
  respond_to  :html, :xml, :json
  load_and_authorize_resource

  def move_to_top
    @attaching.move_to_top
    respond_with @attaching, location: safe_referer_url_with_requested_tab
  end

end
