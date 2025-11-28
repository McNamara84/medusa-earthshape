class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :adjust_url_by_requesting_tab
  helper_method :safe_referer_url

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, :set_current_user
  before_action :set_searchable_records, if: Proc.new {|controller| controller.current_user }
  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied, with: :deny_access

  before_action :basic_authentication, unless: :format_html_or_signed_in?  # Rails 5.1: before_filter → before_action

  def basic_authentication
    authenticate_or_request_with_http_basic do |name, password|
      resource = User.find_by(username: name)
      if resource.valid_password?(password)
        sign_in :user, resource
      end
    end
  end

  def format_html_or_signed_in?
    request.format.html? || user_signed_in?
  end

  def configure_permitted_parameters
    # Devise 4.x: changed from .for() to .permit()
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation, :remember_me])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username, :password, :remember_me])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :password, :password_confirmation, :current_password])
  end
  
  def set_current_user
    User.current = current_user
  end

  def set_searchable_records
    # Use strong parameters for security and handle nil case
    # Consistent with other controllers using ransack
    @records_search = RecordProperty.ransack(params[:q]&.permit! || {})
  end

  def adjust_url_by_requesting_tab(url)
    return url if params[:tab].blank?
    work_url = url.sub(/tab=.*&/,"").sub(/\?tab=.*/,"")
    work_url + (work_url.include?("?") ? "&" : "?") + "tab=#{params[:tab]}"
  end

  # Returns a safe referer URL that only allows redirects to the same origin.
  # This is used with respond_with to prevent open redirect vulnerabilities
  # while maintaining the legacy pattern of redirecting to the referring page.
  # Falls back to root_path if referer is missing or from a different origin.
  #
  # Validates:
  # - Same host (prevents redirects to different domains)
  # - Same port (prevents redirects to different services on same host)
  # - Same scheme (prevents protocol downgrade attacks http <-> https)
  #
  # Accepts:
  # - Same-origin absolute URLs (e.g., "http://example.com:80/path")
  # - Relative URLs (e.g., "/path" or "path") - implicitly same-origin
  # - URLs without host - treated as same-origin
  # - URLs with fragments (e.g., "/path#section")
  def safe_referer_url
    referer = request.referer
    return root_path if referer.blank?

    begin
      referer_uri = URI.parse(referer)
      
      # Allow relative URLs (no host means same-origin)
      return referer if referer_uri.host.nil?
      
      # For absolute URLs, verify same origin (host, port, and scheme)
      request_uri = URI.parse(request.url)
      same_host = referer_uri.host == request_uri.host
      same_port = referer_uri.port == request_uri.port
      same_scheme = referer_uri.scheme == request_uri.scheme
      
      if same_host && same_port && same_scheme
        referer
      else
        root_path
      end
    rescue URI::InvalidURIError
      root_path
    end
  end

  protected

  def verified_request?
    # REST-API対応のため、主要ブラウザ以外はcsrf-tokenをチェックしない
    super || request.user_agent !~ /^(Mozilla|Opera)/
  end

  private
  
  def deny_access
    respond_to do |format|
      format.html { render "parts/access_denied", status: :forbidden }
      format.all { head :forbidden }
    end
  end

end
