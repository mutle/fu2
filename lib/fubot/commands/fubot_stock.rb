Fubot.command /stock @?([A-Za-z0-9.-_]+)\s?(\d+\w+)?/i do
  def help
    ["stock", "Look up stock info"]
  end

  def call(bot, args, message)
    ticker = args[1]
    time = args[2] || '1d'
    open("http://finance.google.com/finance/info?client=ig&q=#{URI::encode ticker}") do |result|
      resp = JSON.parse(result.read.gsub(/\/\/ /, ''))
      m = "![](http://chart.finance.yahoo.com/z?s=#{ticker}&t=#{time}&q=l&l=on&z=l&a=v&p=s&lang=en-US&region=US#.png)"
      m << "\n#{resp[0]['l_cur']} (#{resp[0]['c']})"
      bot.reply m
    end
  end
end
