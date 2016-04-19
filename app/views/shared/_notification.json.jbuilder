json.(notification, :id, :user_id, :created_by_id, :reference_notification_id, :notification_type, :channel_id, :post_id, :message, :created_at, :read)
json.message_raw notification.message(false)
json.type "notification"

if notification.notification_type == "mention"
  json.post do
    json.partial! 'shared/post', post: notification.post
  end
  json.channel do
    json.partial! 'shared/channel', channel: notification.channel
  end
end
