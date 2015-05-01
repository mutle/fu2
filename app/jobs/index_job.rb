class IndexJob < Resque::Job
  @queue = :indexer

  def self.perform(type, ids)
    new(type, ids).perform
  end

  def initialize(type, ids)
    @type = type.to_s
    @ids = ids.is_a?(Array) ? ids : [ids]
  end

  def perform
    items = []
    if @type == "channels"
      items = Channel.with_ids(@ids)
    elsif @type == "posts"
      items = Post.with_ids(@ids)
    end
    s = items.size
    items.each_with_index do |item,i|
      Search.index_doc(@type, item, i, s)
    end
  end
end
