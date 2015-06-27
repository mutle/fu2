module Views
  class NotificationCounts < ApplicationView

    attrs :current_user

    fetches :message_counts, proc {
      n = Notification.for_user(current_user).messages
      n.load
      counts = {}
      n.each do |notification|
        next if notification.created_by_id == current_user.id
        counts[notification.created_by_id] ||= 0
        if !notification.read
          counts[notification.created_by_id] += 1
        end
        p counts
      end
      p counts
      counts
    }

    fetches :mention_counts, proc {
      n = Notification.for_user(current_user).mentions
      n.load
      counts = {}
      n.each do |notification|
        next if notification.created_by_id == current_user.id
        counts[notification.created_by_id] ||= 0
        if !notification.read
          counts[notification.created_by_id] += 1
        end
      end
      counts
    }

  end
end
