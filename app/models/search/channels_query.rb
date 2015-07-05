class Search
  class ChannelsQuery < Query

    def index
      "channels"
    end

    def index_type
      "channel"
    end

    def default
      [
        :title,
        :text
      ]
    end

    def searchable
      [
        :title,
        :created,
        :text
      ]
    end

    def boost
      {
        title: 5
      }
    end

    def wildcard
      [
        :title
      ]
    end

    def fetch_objects(query)
      return [] if !query || !query['hits'] || !query['hits']['hits']
      ids = query['hits']['hits'].map { |h| h['_id'] }
      order_by_ids ids, Channel.with_ids(ids).load
    end

  end
end
