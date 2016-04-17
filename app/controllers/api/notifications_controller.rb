class Api::NotificationsController < Api::ApiController
  def index
    if params[:format].to_s == "json"
      page = (params[:page] || 1).to_i
      per_page = (params[:per_page] || 25).to_i
      @view = Views::NotificationList.new({
        current_user: current_user,
        page: page,
        per_page: per_page,
        include_posts: true,
        site: @site
      })
      @view.finalize
      respond_with @view.notifications
    end
  end

  def show
    if params[:format].to_s == "json"
      user = User.find(params[:id])
      @view = Views::NotificationList.new({
        current_user: current_user,
        user: user,
        last_id: params[:last_id].to_i,
        site: @site
      })
      @view.finalize
      respond_with @view.notifications
    end
  end

  def create
    to = User.find(params[:user_id])
    @message = {}
    if to
      @message = siteNotification.message(current_user, to, params[:message])
    end
    respond_with @message
  end

  def read
    from = User.find(params[:id])
    Notification.mark_unread(current_user, from)
    status = {"status" => "ok"}
    respond_with status, :location => notifications_path
  end

  def unread
    @view = Views::NotificationCounts.new({
      current_user: current_user,
      site: @site
    })
    @view.finalize
    render json: {messages: @view.message_counts, mentions: @view.mention_counts}
  end

  def unread_users
    @view = Views::NotificationCounts.new({
      current_user: current_user,
      site: @site
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
    @view = Views::CurrentUserView.new({current_user: user, site: @site})
    @view.finalize
    return @view.counters
  end
end
