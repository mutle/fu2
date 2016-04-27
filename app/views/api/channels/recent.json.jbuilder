json.active_channels @view.active_channels do |channel|
  json.partial! 'shared/channel', channel: channel, show: true
end

json.best_posts @view.best_posts do |post|
  json.partial! 'shared/post', post: post
end

json.active_users @view.active_users
json.active_emojis @view.active_emojis
