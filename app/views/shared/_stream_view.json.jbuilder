json.view do
  json.count view.count
  json.start_id view.start_id
  json.end_id view.end_id
  json.last_update view.last_update

  json.last_read_id view.last_read_id
  json.per_page view.per_page
end
