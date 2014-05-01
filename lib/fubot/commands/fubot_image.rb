module ImageSearch
  class << self

    def imageMe(query, animated=false, faces=false)
      # cb = animated if typeof animated == 'function'
      # cb = faces if typeof faces == 'function'
      # q = v: '1.0', rsz: '8', q: query, safe: 'active'
      # q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
      # q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
      img = ""
      img = "&imgtype=animated" if animated
      query = "q=#{URI::encode query}&v=1.0&safe=off&rsz=8#{img}"
      open("http://ajax.googleapis.com/ajax/services/search/images?#{query}") do |result|
        images = JSON.parse(result.read)
        images = images['responseData']['results']
        if images && images.size > 0
          s = images.size - 1
          s = 1 if !s || s <= 0
          r = rand(s)
          image = images[r]
          yield image['unescapedUrl']
        end
      end
    end

  end
end

Fubot.command /image (.*)/ do
  def help
    ["image", "Searches for an image"]
  end

  def call(bot, args, message)
    ImageSearch.imageMe args[1] do |url|
      bot.reply "![](#{url})"
    end
  end
end


Fubot.command /gif (.*)/ do
  def help
    ["gif", "Searches for an animated gif"]
  end

  def call(bot, args, message)
    ImageSearch.imageMe args[1], true do |url|
      bot.reply "![](#{url})"
    end
  end
end
