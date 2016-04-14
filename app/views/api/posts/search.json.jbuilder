json.partial! 'shared/list_view', view: @view

json.sort @view.sort

json.results @view.results[:objects] do |result|
  json.partial! 'shared/post', post: result if result
end
