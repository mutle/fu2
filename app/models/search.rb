class Search

  class << self

    def query(query, options={})
      new(query, options)
    end

    def index(name)
      $elastomer.index index_name(name)
    end

    def docs(name)
      $elastomer.docs index_name(name)
    end

    def update_index
      setup_index

      count = Channel.count
      Channel.all.each_with_index { |c,i| index_doc("channels", c, i, count) }
      count = Post.count
      Post.all.each_with_index { |p,i| index_doc("posts", p, i, count) }
    end

    def build_index(name, klass)
      i = index(name)
      i.create(klass.index_definition) if !i.exists?
    end

    def index_name(name)
      "#{name}-#{Rails.env}"
    end

    def reset_index
      %w(channels posts).each do |name|
        i = index(name)
        i.delete if i.exists?
      end
    end

    def setup_index
      build_index "channels", Channel
      build_index "posts", Post
    end

    def index_doc(name, obj, n, count)
      data = obj.to_indexed_json
      return if data.keys.size < 1
      d = docs(name)
      Rails.logger.info "+#{index_name name}: #{data[:id]} (#{n+1}/#{count})"
      d.index(data)
    end

    def remove_doc(name, id, type, n, count)
      d = docs(name)
      Rails.logger.info "-#{index_name name}: #{id} (#{n+1}/#{count})"
      d.delete(id: id, type: type)
    end

    def update(name, id)
      Resque.enqueue(IndexJob, :update, name, id)
    end

    def remove(name, id)
      Resque.enqueue(IndexJob, :remove, name, id)
    end

  end

  attr_accessor :query

  QUERIES = [ChannelsQuery, PostsQuery]

  def initialize(query, options={})
    @query = parse_query query
    @options = options
    @results = nil
    @per_page = options.fetch(:per_page, 25)
    @options[:per_page] = @per_page
  end

  def parse_query(query)
    s = query.to_s.strip
    q = []
    scanner = StringScanner.new(s)
    while !scanner.eos?
      if scanner.scan /\"([\w ]+)\"/
        q << scanner[1]
      elsif scanner.scan /((\w+):)?(\w+)/
        if scanner[2]
          q << [scanner[3], scanner[2]]
        else
          q << scanner[3]
        end
      else
        scanner.getch
      end
    end
    q
  end

  def results
    return @results if @results
    @results = {
      total_count: 0,
      result_count: 0,
      offset: 0,
      objects: []
    }
    n = 0
    enough_results = false
    QUERIES.each do |query|
      r = query.new(@query, @options).results
      @results[:total_count] += r[:total_count]
      @results[:result_count] += r[:result_count]
      @results[:objects] += r[:objects] if !enough_results
      n += r[:objects].size
      if n >= @per_page
        enough_results = true
      end
    end
    @results
  end


end
