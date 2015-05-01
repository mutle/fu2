class Search
  class Query

    def initialize(query)
      @query = query
    end

    def perform
      i = Search.index(index)
      r = i.multi_search do |m|
        m.search({:query => {:match_all => {}}}, :search_type => :count)
        m.search({:query => search_query}, :type => index_type)
      end
      res = r['responses']
      {
        total_count: res[0]['hits']['total'],
        objects: fetch_objects(res[1])
      }
    end

    def results
      perform
    end

    def order_by_ids(ids, objects)
      t = {}
      objects.each do |o|
        t[o.id.to_s] = o
      end
      ids.map { |i| t[i] }
    end

    def fetch_objects(query)
      []
    end
    def index
    end
    def index_type
    end
    def search_query
      {}
    end
    def searchable
      []
    end
  end
end
