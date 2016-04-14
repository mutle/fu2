class Search
  class Query

    include ActiveSupport::Benchmarkable

    class << self
      def index
        ""
      end
    end

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
      benchmark "Search query #{query} on #{index_type} sort #{s} offset #{@options[:offset]}" do
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

    def search_query_for(field, query)
      if wildcard.include?(field.to_sym)
        [
          {
            wildcard: {
              field => {
                wildcard: query.downcase,
                boost: 1
              }
            }
          },
          {
            match: {
              field => {
                query: query,
                boost: boost_for(field),
                operator: "and"
              }
            }
          }
        ]
      else
        [
          {
            match: {
              field => {
                query: query,
                boost: boost_for(field),
                operator: "and"
              }
            }
          }
        ]
      end
    end

    def search_query
      q = {bool:{should:[], must:[]}}
      should = q[:bool][:should]
      must = q[:bool][:must]
      default.each do |a|
        query_for(a).each do |t|
          p = should
          p = must if t[0] == '+'
          search_query_for(a, t.gsub(/^\+/, '')).each do |q|
            p << q
          end
        end
      end
      searchable.each do |a|
        query_for(a, true).each do |t|
          search_query_for(t[1], t[0]).each do |q|
            should << q
          end
        end
      end
      return nil if should.size < 1 && must.size < 1
      q[:bool].delete(:should) if q[:bool][:should].size < 1
      q[:bool].delete(:must) if q[:bool][:must].size < 1
      q
    end

    def sort(s='created')
      if s == "score"
        return [
          { _score: { order: "desc" }}
        ]
      end
      return nil unless searchable.map(&:to_s).include?(s)
      [
        { s =>    { order: "desc" }},
        { _score: { order: "desc" }}
      ]
    end

    def wildcard_query(t)
      t.is_a?(String) ? t.gsub(/^(\+?)(.*)$/, "\\1*\\2*") : t.join(" ")
    end

    def query_for(attribute, optional=false)
      q = []
      @query.each do |term|
        if optional
          next if !term.is_a?(Array) || term[1] != attribute.to_s
          q << [wildcard_query(term[0]), term[1]]
        else
          next if term.is_a?(Array)
          if term.include?(" ")
            q << term
          else
            q << wildcard_query(term)
          end
        end
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
    def wildcard
      []
    end
  end
end
