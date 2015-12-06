class Search
  class PostsQuery < Query

    class << self
      def index
        "posts"
      end
    end

    def index
      "posts"
    end

    def index_type
      "post"
    end

    def default
      [
        :body
      ]
    end

    def searchable
      [
        :body,
        :created,
        :user,
        :faves,
        :faver,
        :mention
      ]
    end

    def fetch_objects(query)
      return [] if !query || !query['hits'] || !query['hits']['hits']
      ids = query['hits']['hits'].map { |h| h['_id'] }
      order_by_ids ids, Post.with_ids(ids).includes(:user, :channel, :faves => [:user]).load
    end
  end
end
