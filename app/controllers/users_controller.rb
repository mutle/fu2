class UsersController < ApplicationController
  
  before_filter :login_required, :except => ["activate", "create"]
  
  def index
    @users = User.all_users
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
    @user = User.find(params[:id])
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @invite = Invite.find_by_activation_code(params[:user][:activation_code])
    raise ActiveRecord::RecordNotFound unless @invite
    @user = User.new(params[:user].merge(:email => @invite.email))
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
  
  def update
    if params[:id].to_i == current_user.id
      @user = current_user
      @user.update_attributes(:display_name => params[:user][:display_name], :color => params[:user][:color], :stylesheet_id => params[:user][:stylesheet_id].to_i)
      if @user.valid?
        redirect_to user_path(User.find(params[:id].to_i))
      else
        render :action => "edit"
      end
    else
      redirect_to user_path(User.find(params[:id].to_i))
    end
  end
  
  # def activate
  #   self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
  #   if logged_in? && !current_user.active?
  #     current_user.activate
  #     flash[:notice] = "Signup complete!"
  #   end
  #   redirect_back_or_default('/')
  # end

end
