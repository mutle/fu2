class Search
  class Query

    include ActiveSupport::Benchmarkable

    def initialize(query=nil, options={})
      @query = query
      @options = options
    end

    def perform
      i = Search.index(index)
      query = search_query
      if @query.size == 0
        query = {:match_all => {}}
      end
      s = sort(@options[:sort])
      r = nil
      benchmark "Search query #{query} on #{index_type} sort #{sort} offset #{@options[:offset]}" do
        r = i.multi_search do |m|
          m.search({:query => {:match_all => {}}}, :search_type => :count)
          m.search({:query => query, :sort => s, :from => @options[:offset], :size => @options[:per_page]}, :type => index_type) if query && s
        end
      end
      res = r['responses']
      res.each do |result|
        p result['error'] if result['error']
      end
      {
        total_count: res[0]['hits']['total'],
        result_count: res[1] ? res[1]['hits']['total'] : 0,
        objects: res[1] ? fetch_objects(res[1]) : [],
        scores: res[1] ? res[1]['hits']['hits'].map { |h| h['_score'] } : []
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
      q = {bool:{should:[], must:[]}}
      should = q[:bool][:should]
      must = q[:bool][:must]
      default.each do |a|
        query_for(a).each do |t|
          should << {
            match: {
              a => {
                query: wildcard(t),
                boost: boost_for(a)
              }
            }
          }
        end
      end
      searchable.each do |a|
        query_for(a, true).each do |t|
          must << {
            match: {
              t[1] => {
                query: wildcard(t[0]),
                boost: boost_for(t[1])
              }
            }
          }
        end
      end
      return nil if should.size < 1 && must.size < 1
      q
    end

    def sort(s='created')
      return nil unless searchable.map(&:to_s).include?(s)
      [
        { s =>    { order: "desc" }},
        { _score: { order: "desc" }}
      ]
    end

    def wildcard(t)
      "*#{t.split(" ").join("* *")}*"
    end

    def query_for(attribute, optional=false)
      q = []
      @query.each do |term|
        next if !optional && term.is_a?(Array)
        next if optional && (!term.is_a?(Array) || term[1] != attribute.to_s)
        q << term
      end
      q
    end

    def logger
      Rails.logger
    end

    def boost_for(attribute)
      boost[attribute] || 1
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
    def boost
      {}
    end
  end
end
