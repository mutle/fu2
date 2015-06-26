module Views
  class Search < ApplicationView

    attrs :query, :start, :sort, :per_page

    fetches :results, proc {
      ::Search.query(query, per_page: per_page, offset: start, sort: sort).results
    }

  end
end
