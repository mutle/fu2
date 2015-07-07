module Views
  class ListView < ApplicationView
    attrs :page, :per_page
    fetches :count, proc { 0 }
    fetches :start_index, proc { 0 }
    fetches :end_index, proc { 0 }
  end
end
