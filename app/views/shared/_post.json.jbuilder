if post.is_a?(Event)
  json.type "event"
  json.(post, :id, :channel_id, :created_at, :updated_at, :user_id, :event, :message)
else
  json.type "post"
  json.(post, :id, :channel_id, :created_at, :updated_at, :user_id, :body, :html_body, :markdown, :read)
  json.faves post.faves do |fave|
    json.partial! "shared/fave", fave: fave
  end
end
