if post.is_a?(Event)
  json.object_type "event"
  json.type "channel-#{post.channel_id}-event"
  json.(post, :id, :channel_id, :created_at, :updated_at, :user_id, :event, :message, :html_message)
else
  json.object_type "post"
  json.type "channel-#{post.channel_id}-post"
  json.(post, :id, :channel_id, :created_at, :updated_at, :user_id, :body, :html_body, :markdown, :read)
  json.faves post.faves do |fave|
    json.partial! "shared/fave", fave: fave
  end
end
