json.channel do
  json.partial! 'shared/channel', channel: @channel
  json.last_read_id @view.last_read_id
  json.last_update @view.last_update
end

json.posts @view.posts do |post|
  json.partial! 'shared/post', post: post
end
