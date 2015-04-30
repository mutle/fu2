module Views
  class NotificationList < ApplicationView

    attrs :current_user, :last_id

    fetches :notifications, proc {
      n = Notification.for_user(current_user).includes(:user, :channel, :post)
      n = n.since(last_id) if last_id > 0
      n.load
      n
    }

  end
end
