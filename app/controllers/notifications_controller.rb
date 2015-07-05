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
      Live.notification_counters(to)
    end
    respond_with @message
  end

  def read
    from = User.find(params[:id])
    Notification.for_user(current_user).toolbar_notifications.from_user(from).unread.update_all(:read => true)
    Live.notification_counters(current_user)
    status = {"status" => "ok"}
    respond_with status, :location => notifications_path
  end

  def unread
    @view = Views::NotificationCounts.new({
      current_user: current_user
    })
    @view.finalize
    result = User.active.map do |u|
      if u.id == current_user.id
        current_user.as_json.merge(messages: nil, mentions: nil)
      else
        u.as_json.merge(messages: @view.message_counts[u.id], mentions: @view.mention_counts[u.id])
      end
    end
    respond_with result
  end

  def counters
    result = update_counters(current_user)
    respond_with result
  end

  private

  def update_counters(user)
    @view = Views::CurrentUserView.new({current_user: user})
    @view.finalize
    return @view.counters
  end
end
