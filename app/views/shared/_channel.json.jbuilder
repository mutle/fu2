json.(channel, :id, :created_at, :updated_at, :last_post_date, :title, :permalink)
json.type "channel"
json.last_post_id channel.last_post.id
json.last_post_user_id channel.last_post_user_id
json.display_name format_title(channel.title)
json.display_date (channel.last_post_date || channel.updated_at).to_i * 1000
