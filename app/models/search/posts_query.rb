class Search
  class PostsQuery < Query

    def index
      "posts"
    end

    def index_type
      "post"
    end

    def search_query
      {
        match: {
          body: @query.first
        }
      }
    end

    def searchable
      [
        :body,
        :created_at,
        :user
      ]
    end

    def fetch_objects(query)
      return [] if !query || !query['hits'] || !query['hits']['hits']
      ids = query['hits']['hits'].map { |h| h['_id'] }
      order_by_ids ids, Post.with_ids(ids).load
    end
  end
end
