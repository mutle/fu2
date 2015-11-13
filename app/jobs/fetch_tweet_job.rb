class FetchTweetJob
  @queue = :fetch

  def self.perform(id, post_id=nil, type=:tweet)
    new(id, post_id, type).perform
  end

  def initialize(id, post_id=nil, type=:tweet)
    @id = id
    @post_id = post_id
    @type = type.to_sym
    Rails.logger.info @type
  end

  def redis_key
    if @type == :tweet
      "Tweets:#{@id}"
    elsif @type == :instagram
      "Instagram:#{@id}"
    end
  end

  def conn_for(url)
    conn = Faraday.new(:url => url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def get_embed_code
    if @type == :tweet
      response = conn_for('https://api.twitter.com').get "/1/statuses/oembed.json?id=#{@id}&width=600&omit_script=true"
      tweet = MultiJson.decode response.body
      tweet['html']
    elsif @type == :instagram
      response = conn_for('http://api.instagram.com').get "/oembed?url=http://instagr.am/p/#{@id}"
      image = MultiJson.decode response.body
      image['html']
    end
  end

  def perform
    return if $redis.get redis_key

    $redis.set redis_key, get_embed_code
    if @post_id
      p = Post.find(@post_id)
      p.touch
      p.notify_update
    end
  end
end
