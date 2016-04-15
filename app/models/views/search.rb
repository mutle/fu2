module Views
  class Search < ListView

    attrs :query, :sort, :type, :per_page

    fetches :results, proc {
      ::Search.query(query, type: type, per_page: per_page, offset: ((page - 1) * per_page), sort: sort).results
    }
    fetches :highlight_query, proc {
      results[:objects].each do |post|
        if post.respond_to?(:query=)
          post.query = {"text" => query}
        end
      end
      nil
    }, [:results]

    fetches :last_update, proc { Time.now }
    fetches :count, proc { results[:result_count] }, [:results]
    fetches :end_index, proc { (page - 1) * per_page + results[:objects].size }, [:results]

  end
end
