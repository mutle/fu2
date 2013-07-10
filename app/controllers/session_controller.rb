# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  
  layout 'unauthorized'

  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      Rails.logger.info "logged in"
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      Rails.logger.info "login failed"
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  def change_password
  end

  def authenticate
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      self.current_user.enable_api_usage
      render :json => {:api_key => self.current_user.api_key}
    else
      render :json => {:fail => true}
    end
  end
end
