class InvitesController < ApplicationController
  
  before_filter :login_required
  
  def new
    raise ActiveRecord::NotFound unless current_user.can_invite?
  end
  
  def create
    if current_user.can_invite?
      @invite = Invite.create(params[:invite].merge(:user_id => current_user.id))
      flash[:notice] = "The invite was created." # and will be sent as soon as three other users approve. 
    end
    redirect_to root_path
  end
  
  def approve
    @invite = Invite.find(params[:id])
    if @invite.approve(current_user)
      flash[:notice] = "The invite was approved"
    else
      
    end
    
    redirect_to root_path
  end
  
end
