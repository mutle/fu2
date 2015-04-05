json.channel do
  json.partial! 'shared/channel', channel: @channel
  json.last_read_id @last_read_id
  json.last_update @last_update
end

json.posts @posts do |post|
  json.partial! 'shared/post', post: post
end
