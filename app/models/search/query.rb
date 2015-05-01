class Search
  class Query

    def initialize(query=nil, options={})
      @query = query
      @options = options
    end

    def perform
      i = Search.index(index)
      p search_query
      r = i.multi_search do |m|
        m.search({:query => {:match_all => {}}}, :search_type => :count)
        m.search({:query => search_query, :size => @options[:per_page]}, :type => index_type)
      end
      res = r['responses']
      res.each do |result|
        p result['error'] if result['error']
      end
      {
        total_count: res[0]['hits']['total'],
        result_count: res[1]['hits']['total'],
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

    def search_query
      q = {bool:{must:[]}}
      p = q[:bool][:must]
      default.each do |a|
        query_for(a).each do |t|
          p << {
            match: {
              a => t
            }
          }
        end
      end
      searchable.each do |a|
        query_for(a, true).each do |t|
          p << {
            match: {
              t[1] => t[0]
            }
          }
        end
      end
      q
    end

    def query_for(attribute, optional=false)
      q = []
      @query.each do |term|
        next if !optional && term.is_a?(Array)
        next if optional && !term.is_a?(Array) && term[1] != attribute
        q << term
      end
      q
    end

    def fetch_objects(query)
      []
    end
    def index
    end
    def index_type
    end
    def searchable
      []
    end
    def default
      []
    end
  end
end
