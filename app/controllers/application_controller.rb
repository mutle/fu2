class ApplicationController < ActionController::Base
  protect_from_forgery

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

  def notification(type, object, user_id=0)
    $redis.publish 'live', {:type => type, :user_id => user_id, :object => object.as_json}.to_json
  end

  def increment_metric(name)
    METRICS.increment name
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

end
