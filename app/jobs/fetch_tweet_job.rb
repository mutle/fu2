class FetchTweetJob
  @queue = :fetch

  def self.perform(id)
    new(id).perform
  end

  def initialize(id)
    @id = id
  end

  def perform
    conn = Faraday.new(:url => 'https://api.twitter.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    response = conn.get "/1/statuses/oembed.json?id=#{@id}&width=600"
    tweet = MultiJson.decode response.body
    $redis.set "Tweets:#{@id}", tweet["html"]
  end
end
