class InvitesController < ApplicationController

  before_filter :login_required

  def new
    raise ActiveRecord::NotFound unless current_user.can_invite?
  end

  def create
    if current_user.can_invite?
      @invite = Invite.create(invite_params.merge(:user_id => current_user.id))
      p @invite
      url = activate_user_url(@invite.activation_code)
      flash[:notice] = "The invite was approved (#{url})"
    end
    redirect_to root_path
  end

  def approve
    @invite = Invite.find(params[:id])
    if @invite.approve(current_user)
      url = activate_user_url(@invite)
      flash[:notice] = "The invite was approved (#{url})"
    else

    end

    redirect_to root_path
  end

  private
  def invite_params
    params.require(:invite).permit(:name, :email)
  end

end
