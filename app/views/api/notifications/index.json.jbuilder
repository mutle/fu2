json.partial! 'shared/list_view', view: @view
json.notifications @view.notifications do |n|
  json.partial! 'shared/notification', notification: n
end
