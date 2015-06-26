module Views
  class NotificationList < ApplicationView

    attrs :current_user

    fetches :message_counts, proc {
      n = Notification.for_user(current_user).messages
      n.load
      p n
      counts = {}
      n.map do |notification|
        next if notification.created_by_id == current_user.id
        counts[notification.created_by_id] ||= 1
        if !n.read
          counts[notification.created_by_id] += 1
        end
      end
      counts
    }

    fetches :mention_counts, proc {
      n = Notification.for_user(current_user).mentions
      n.load
      p n
      counts = {}
      n.map do |notification|
        next if notification.created_by_id == current_user.id
        counts[notification.created_by_id] ||= 1
        if !n.read
          counts[notification.created_by_id] += 1
        end
      end
      counts
    }

  end
end
