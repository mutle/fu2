json.partial! 'shared/list_view', view: @view
json.channels @view.recent_channels do |c|
  json.partial! 'shared/channel', channel: c, type: @view.type
  json.read c.read
end
