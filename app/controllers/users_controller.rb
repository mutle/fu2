class UsersController < ApplicationController
  respond_to :html

  def activate
    # if current_user
    #   redirect_to user_path(current_user.id)
    # else
    @invite = Invite.find_by_activation_code(params[:id])
    raise ActiveRecord::RecordNotFound unless @invite
    @user = User.new(:login => @invite.name, :email => @invite.email, :invite_user_id => @invite.id)
    @user.activation_code = @invite.activation_code
    render :action => "new", :layout => "unauthorized"
    # end
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @invite = Invite.find_by_activation_code(params[:user][:activation_code])
    raise ActiveRecord::RecordNotFound unless @invite
    @user = User.new(user_params.merge(:email => @invite.email))
    @user.save
    if @user.valid?
      @user.activate
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      @user.activation_code = @invite.activation_code
      render :action => 'new', :layout => 'unauthorized'
    end
  end

  private
  def user_params
    params.require(:user).permit(:login, :password, :password_confirmation, :invite_user_id, :activation_code)
  end
end
