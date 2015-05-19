module Views
  class Search < ApplicationView

    attrs :query, :start, :sort

    fetches :results, proc {
      ::Search.query(query, offset: start, sort: sort).results
    }

  end
end
