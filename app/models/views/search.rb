module Views
  class Search < ApplicationView

    attrs :query, :page

    fetches :results, proc {
      Search.query(query, page: page).results
    }

  end
end
