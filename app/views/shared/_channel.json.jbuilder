type ||= "channel"
show ||= false
json.(channel, :id, :created_at, :updated_at, :last_post_date, :title, :text, :permalink, :read)
json.type type
json.last_post_id channel.last_post.try(:id)
json.last_post_user_id channel.last_post_user_id
json.updated_by_user_id channel.updated_by_user.try(&:id) || 0
json.display_name format_title(channel.title, channel.query)
json.display_text format_text(channel.text, channel.query)
json.display_date (channel.last_post_date || channel.updated_at).to_i * 1000
if show
  json.last_text_change channel.last_text_change
end
