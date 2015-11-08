if @channel.errors.any?
  json.errors @channel.errors
end

json.channel do
  json.partial! 'shared/channel', channel: @channel
end
