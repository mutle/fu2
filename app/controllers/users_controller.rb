class UsersController < ApplicationController

  before_filter :login_required, :except => ["activate", "create"]

  respond_to :html, :json

  def index
    @users = User.all_users
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
    @user = begin
      User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      User.first(:conditions => ["LOWER(login) = LOWER(?)", params[:id]]) || raise(ActiveRecord::RecordNotFound)
    end
    @column_width = 12
    respond_with @user
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
      if !params[:user][:email].blank?
        @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation], :email => params[:user][:email])
      else
        @user.update_attributes(:display_name => params[:user][:display_name], :color => params[:user][:color], :stylesheet_id => params[:user][:stylesheet_id].to_i, :markdown => params[:user][:markdown], :new_features => params[:user][:new_features] == "1", :avatar_url => params[:user][:avatar_url])
      end
      if @user.valid?
        redirect_to user_path(User.find(params[:id].to_i))
      else
        @user.password_confirmation = @user.password = nil
        if params[:user][:email]
          render :action => "password"
        else
          render :action => "edit"
        end
      end
    else
      redirect_to user_path(User.find(params[:id].to_i))
    end
  end

  def block
    @user = current_user
    block_user = User.find(params[:id].to_i)
    @user.block_user(block_user)
    @user.save
  end

  # def activate
  #   self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
  #   if logged_in? && !current_user.active?
  #     current_user.activate
  #     flash[:notice] = "Signup complete!"
  #   end
  #   redirect_back_or_default('/')
  # end

  def password
    if current_user && params[:id].to_i == current_user.id
      @user = current_user
    else
      redirect_to user_path(User.find(params[:id].to_i))
    end
  end

end
