if post.is_a?(Event)
  json.object_type "event"
  if @tag
    json.type "channel-tag-#{@tag}-event"
  else
    json.type "channel-#{post.channel_id}-event"
  end
  json.(post, :id, :channel_id, :created_at, :updated_at, :user_id, :event, :message, :html_message, :data)
elsif post
  json.object_type "post"
  if @tag
    json.type "channel-tag-#{@tag}-post"
  else
    json.type "channel-#{post.channel_id}-post"
  end
  json.(post, :id, :channel_id, :created_at, :updated_at, :user_id, :body, :markdown, :read)
  if @current_user
    json.html_body post.html_body(@current_user)
  else
    json.html_body post.html_body
  end
  json.faves post.faves do |fave|
    json.partial! "shared/fave", fave: fave
  end
end
