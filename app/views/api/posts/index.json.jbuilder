json.partial! 'shared/stream_view', view: @view

if @channel
  json.channel do
    json.partial! 'shared/channel', channel: @channel, show: true
    json.last_read_id @view.last_read_id
    json.last_update @view.last_update
  end
end

json.posts @view.posts do |post|
  json.partial! 'shared/post', post: post
end
