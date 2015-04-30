class NotificationsController < ApplicationController

  before_filter :login_required

  respond_to :html, :json

  def index
    if params[:format].to_s == "json"
      @view = Views::NotificationList.new({
        current_user: current_user,
        last_id: params[:last_id].to_i
      })
      @view.finalize
      respond_with @view.notifications
    else
      @column_width = 12
    end
  end

  def create
    to = User.find(params[:user_id])
    @message = {}
    if to
      @message = Notification.message(current_user, to, params[:message])
    end
    respond_with @message
  end

  def read
    from = User.find(params[:id])
    Notification.for_user(current_user).toolbar_notifications.from_user(from).unread.update_all(:read => true)
    status = {"status" => "ok"}
    respond_with status, :location => notifications_path
  end
end
