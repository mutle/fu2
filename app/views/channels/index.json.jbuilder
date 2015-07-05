json.channels @view.recent_channels do |c|
  json.partial! 'shared/channel', channel: c
  json.read !c.has_posts?(current_user)
end
