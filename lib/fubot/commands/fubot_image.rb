require 'open-uri'
require 'json'

Fubot.command /image (.*)/ do
  def help
    ["image", "Searches for an image"]
  end

  def imageMe(bot, query, animated=false, faces=false)
    # cb = animated if typeof animated == 'function'
    # cb = faces if typeof faces == 'function'
    # q = v: '1.0', rsz: '8', q: query, safe: 'active'
    # q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
    # q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
    query = "q=#{URI::encode query}&v=1.0&safe=active&rsz=8"
    open("http://ajax.googleapis.com/ajax/services/search/images?#{query}") do |result|
      images = JSON.parse(result.read)
      images = images['responseData']['results']
      if images && images.size > 0
        s = images.size - 1
        s = 1 if !s || s <= 0
        r = rand(s)
        image = images[r]
        bot.reply "![](#{image['unescapedUrl']}#.png)"
      end
    end
  end


  def call(bot, args, message)
    imageMe bot, args[1]
  end
end
