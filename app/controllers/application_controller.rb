class ApplicationController < ActionController::Base
  SESSION_KEY_WARNING_MUTEX = Mutex.new

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Medusa also exposes a REST API (JSON/XML/etc.) authenticated via HTTP Basic
  # (see README). These clients are typically stateless and do not have a CSRF
  # token or a browser session cookie.
  #
  # We keep strict CSRF protection for browser (cookie-session) requests, but
  # skip it for stateless API requests that:
  # - are non-HTML
  # - include an Authorization header
  # - do NOT include the Rails session cookie
  prepend_before_action :authenticate_with_http_basic_for_api, if: :stateless_api_request?
  skip_before_action :verify_authenticity_token, if: :stateless_api_request?

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

  def authenticate_with_http_basic_for_api
    authenticate_or_request_with_http_basic do |name, password|
      resource = User.find_by(username: name)

      unless resource&.valid_password?(password)
        logger.warn(
          "[ApplicationController#authenticate_with_http_basic_for_api] Failed HTTP Basic auth " \
          "username=#{name.inspect} ip=#{request.remote_ip} user_agent=#{request.user_agent.to_s.inspect}"
        )

        # Rate limiting is best handled at the edge (reverse proxy) or via a
        # Rack middleware such as Rack::Attack.
        next false
      end

      # Do not create a session for stateless API calls.
      # User.current is thread-local and safe per-request.
      request.env["warden"]&.set_user(resource, scope: :user, store: false)
      User.current = resource
      true
    end
  end

  def format_html_or_signed_in?
    request.format.html? || user_signed_in?
  end

  def stateless_api_request?
    return false if request.format.html?
    return false if request.authorization.blank?

    session_key_error = nil
    session_key = begin
      Rails.application.config.session_options&.[](:key).to_s
    rescue StandardError => e
      session_key_error = e
      ""
    end

    if session_key_error
      should_warn = false
      self.class::SESSION_KEY_WARNING_MUTEX.synchronize do
        unless self.class.instance_variable_defined?(:@_warned_session_key_error)
          self.class.instance_variable_set(:@_warned_session_key_error, true)
          should_warn = true
        end
      end

      if should_warn
        logger.warn(
          "[ApplicationController#stateless_api_request?] Unable to read session_options[:key]: " \
          "#{session_key_error.class}: #{session_key_error.message}"
        )
      end
    end

    return false if session_key.blank?

    cookies[session_key].blank?
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
    # These ivars are request-scoped: Rails instantiates a fresh controller
    # instance per request.
    return @_safe_referer_url if defined?(@_safe_referer_url)

    referer = request.referer
    return (@_safe_referer_url = root_path) if referer.blank?

    begin
      referer_uri = URI.parse(referer)

      # Reject dangerous schemes (e.g. javascript:, data:)
      if referer_uri.scheme.present? && !%w[http https].include?(referer_uri.scheme)
        return (@_safe_referer_url = root_path)
      end

      # Relative URLs (no host means same-origin). Normalize to leading '/'
      # to avoid Rails 8.1 path-relative redirect protections raising, and reject
      # protocol-relative redirects like "//evil.com".
      if referer_uri.host.nil?
        path = referer_uri.path.to_s
        query = referer_uri.query
        fragment = referer_uri.fragment

        return (@_safe_referer_url = root_path) if path.blank?
        return (@_safe_referer_url = root_path) if path.start_with?("//")

        normalized = path.start_with?("/") ? path : "/#{path}"
        normalized += "?#{query}" if query.present?
        normalized += "##{fragment}" if fragment.present?

        return (@_safe_referer_url = normalized)
      end

      # Absolute URLs: verify same origin (host, port, and scheme)
      # Cache parsed request URL for the duration of the request.
      request_uri = @_safe_referer_request_uri ||= URI.parse(request.url)
      same_host = referer_uri.host == request_uri.host
      same_port = referer_uri.port == request_uri.port
      same_scheme = referer_uri.scheme == request_uri.scheme

      @_safe_referer_url = (same_host && same_port && same_scheme) ? referer : root_path
    rescue URI::InvalidURIError
      @_safe_referer_url = root_path
    end
  end

  protected

  private
  
  def deny_access
    respond_to do |format|
      format.html { render "parts/access_denied", status: :forbidden }
      format.all { head :forbidden }
    end
  end

end
