json.(channel, :id, :created_at, :updated_at, :last_post_date, :title, :text, :permalink, :read)
json.type "channel"
json.last_post_id channel.last_post.id
json.last_post_user_id channel.last_post_user_id
json.updated_by_user_id channel.updated_by_user.try(&:id) || 0
json.display_name format_title(channel.title)
json.display_text format_text(channel.text)
json.display_date (channel.last_post_date || channel.updated_at).to_i * 1000
