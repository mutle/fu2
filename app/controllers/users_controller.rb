class UsersController < ApplicationController

  before_filter :login_required, :except => ["activate", "create"]

  respond_to :html, :json

  def index
    @users = User.all_users.reject { |u| u.login =~ /-disabled$/ }
    respond_with @users
  end

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

  def show
    empty_response
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


  def edit
    if params[:id].to_i == current_user.id
      @user = current_user
    else
      redirect_to user_path(User.find(params[:id].to_i))
    end
  end

  private
  def user_params
    params.require(:user).permit(:login, :password, :password_confirmation, :invite_user_id, :activation_code)
  end
end
