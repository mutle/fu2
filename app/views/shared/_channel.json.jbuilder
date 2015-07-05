json.(channel, :id, :created_at, :updated_at, :title, :permalink)
json.last_post_id channel.last_post.id
json.last_post_user_id channel.last_post_user_id
