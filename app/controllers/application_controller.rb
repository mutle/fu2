class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_site_path

  def set_site_path
    @site = request.env['_site']
    Thread.current[:site_id] = @site ? @site.id : nil
  end

  def default_url_options
    if @site
      {site_path: @site.path || ""}
    else
      {}
    end
  end

  def login_required
    logged_in? || redirect_to(new_session_path)
  end

  def current_user
    if params[:api_key]
      @current_user ||= User.find_by_api_key(params[:api_key])
    else
      @current_user ||= User.find(session[:user_id])
    end
  end

  def current_user=(user)
    if user
      @current_user = user
      session[:user_id] = user.id
    else
      @current_user = nil
      session[:user_id] = nil
    end
  end

  def redirect_back_or_default(url)
    redirect_to url
  end

  def logged_in?
    (session[:user_id] || params[:api_key]) && !current_user.nil?
  end

  def highlight_results(text, query)
    query.split(" ").inject(text) { |s,q| s = highlight(s, "<strong>#{q}</strong>") }
  end
  helper_method :highlight_results

  helper_method :current_user

  def mobile_device?
    request.user_agent =~ /(Android|iPhone|iPod|Windows Phone)/
  end
  def mobile_device_blacklisted?
    request.user_agent =~ /(Nexus 7)/
  end
  def mobile?
    params['mobile'] == "true" || (mobile_device? && !mobile_device_blacklisted? && cookies['desktop'] != "true")
  end
  helper_method :mobile_device?
  helper_method :mobile?

  def new_features?
    true # logged_in? && current_user.new_features && params["new_features"] != "false"
  end
  helper_method :new_features?

  protected

  def default_layout
    "application"
  end
end
