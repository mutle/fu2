Fubot.command /ascii (.+)/ do
  def help
    ["ascii", "Create ASCII-Art"]
  end

  def call(bot, args, message)
    open("http://asciime.heroku.com/generate_ascii?s=#{URI::encode args[1].split(' ').join('  ')}") do |result|
      bot.reply "```\n#{result.read}\n```"
    end
  end
end
