class IndexJob < Resque::Job
  @queue = :indexer

  def self.perform(action, type, ids)
    new(action, type, ids).perform
  end

  def initialize(action, type, ids)
    @action = action.to_s
    @type = type.to_s
    @ids = ids.is_a?(Array) ? ids : [ids]
  end

  def perform
    if @action == "remove"
      perform_remove
    else
      perform_index
    end
  end

  def perform_index
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

  def perform_remove
    s = @ids.size
    if @type == "channels"
      type = "channel"
    elsif @type == "posts"
      type = "post"
    else
      return
    end
    @ids.each_with_index do |item,i|
      Search.remove_doc(@type, item, type, i, s)
    end
  end

end
