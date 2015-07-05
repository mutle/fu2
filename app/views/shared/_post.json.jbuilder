if post.is_a?(Event)
  json.type "event"
  json.(post, :created_at, :updated_at, :user_id, :event, :message)
else
  json.type "post"
  json.(post, :id, :created_at, :updated_at, :user_id, :body, :html_body, :markdown)
end
