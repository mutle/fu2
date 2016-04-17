module Views
  class NotificationList < ListView

    attrs :current_user, :user, :last_id, :include_posts

    fetches :notifications, proc {
      n = Notification.site_scope(site).for_user(current_user)
      n = n.from_user(user) if user
      n = n.since(last_id) if last_id && last_id > 0
      n = n.order("created_at DESC").paginate(page: page, per_page: per_page) if page && per_page
      n = n.includes(:user)
      n = n.includes(:post, :channel) if include_posts
      n.load
      n = n.reverse if user
      n
    }

    fetches :count, proc {
      n = Notification.site_scope(site).for_user(current_user)
      n = n.from_user(user) if user
      n.count
    }
    fetches :start_index, proc { (page - 1) * per_page if page }
    fetches :end_index, proc { (page - 1) * per_page + notifications.size if page }, [:notifications]
    fetches :last_update, proc { notifications.map(&:created_at).map(&:utc).max.to_i }, [:notifications]

  end
end
