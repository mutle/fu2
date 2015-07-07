class Api::NotificationsController < Api::ApiController
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
    status = {"status" => "ok"}
    respond_with status, :location => notifications_path
  end

  def unread
    @view = Views::NotificationCounts.new({
      current_user: current_user
    })
    @view.finalize
    render json: {messages: @view.message_counts, mentions: @view.mention_counts}
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
