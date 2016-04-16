class ViewModel

  class << self

    def attrs(*a)
      a.each do |arg|
        attr_accessor arg
      end
    end

    def fetches(arg, callback, depends=[])
      @fetches ||= {}
      @fetches[arg] = {callback: callback, depends: depends}

      define_method arg do
        @fetched[arg]
      end

      define_method "fetch_#{arg}" do
        self.class.fetch(arg, self)
      end
    end

    def fetch(arg, context)
      f = @fetches[arg]
      return false if f[:depends].size > 0 && (f[:depends] - context.fetched.keys).size > 0
      context.fetched[arg] = context.instance_eval &f[:callback]
      true
    end

    def fetch_args
      @fetches.keys
    end

  end

  attr_reader :fetched

  def initialize(attrs={})
    @fetched = {}
    attrs.each do |a,v|
      if respond_to?("#{a}=")
        send("#{a}=", v)
      end
    end
  end

  def finalize
    dependencies = []
    time = Benchmark.ms do
      self.class.fetch_args.each do |arg|
        if !send("fetch_#{arg}")
          dependencies << arg
        end
      end
      while dependencies.size > 0
        d = []
        dependencies.each do |arg|
          if !send("fetch_#{arg}")
            d << arg
          end
        end
        dependencies = d
      end
    end

    Rails.logger.info "view model finalized (#{"%.3f" % time}ms)"
  end

end
