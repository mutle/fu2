json.view do
  json.count view.count
  json.page view.page
  json.per_page view.per_page
  json.start view.start_index
  json.set! :end, view.end_index
  json.last_update view.last_update
end
