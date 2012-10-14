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

  def notification(type, object)
    $redis.publish 'fu2_live', {:type => type, :object => object.as_json}.to_json
  end


  helper_method :current_user
end
