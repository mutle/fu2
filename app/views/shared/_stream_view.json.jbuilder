json.view do
  json.count view.count
  json.last_id @view.last_read_id
  json.last_update @view.last_update
  json.per_page view.per_page
  
end
