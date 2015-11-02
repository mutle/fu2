module Views
  class StreamView < ApplicationView
    attrs :page, :per_page
    fetches :count, proc { 0 }
    fetches :start_id, proc { 0 }
    fetches :end_id, proc { 0 }
    fetches :last_update, proc { 0 }
  end
end
