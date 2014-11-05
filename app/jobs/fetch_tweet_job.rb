class FetchTweetJob
  @queue = :fetch

  def self.perform(id, post_id=nil)
    new(id, post_id).perform
  end

  def initialize(id, post_id=nil)
    @id = id
    @post_id = post_id
  end

  def perform
    return if $redis.get "Tweets:#{@id}"
    conn = Faraday.new(:url => 'https://api.twitter.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    response = conn.get "/1/statuses/oembed.json?id=#{@id}&width=600"
    tweet = MultiJson.decode response.body
    $redis.set "Tweets:#{@id}", tweet["html"]
    Post.find(@post_id).touch if @post_id
  end
end
