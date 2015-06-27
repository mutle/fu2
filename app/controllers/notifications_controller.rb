class NotificationsController < ApplicationController

  before_filter :login_required

  respond_to :html, :json

  def show
    if params[:format].to_s == "json"
      user = User.find(params[:id])
      @view = Views::NotificationList.new({
        current_user: current_user,
        user: user,
        last_id: params[:last_id].to_i
      })
      @view.finalize
      respond_with @view.notifications
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

  def unread
    @view = Views::NotificationCounts.new({
      current_user: current_user
    })
    @view.finalize
    p @view.message_counts
    result = User.active.map do |u|
      next if u.id == current_user.id
      u.as_json.merge(messages: @view.message_counts[u.id], mentions: @view.mention_counts[u.id])
    end
    respond_with result
  end
end
