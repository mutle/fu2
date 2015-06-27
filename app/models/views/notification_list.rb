module Views
  class NotificationList < ApplicationView

    attrs :current_user, :user, :last_id

    fetches :notifications, proc {
      n = Notification.for_user(current_user).from_user(user)
      n = n.since(last_id) if last_id > 0
      n.load
      n.reverse
    }

  end
end
