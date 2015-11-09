Fubot.command /who is @?([^ ]+)\??/i do
  def help
    ["who is", "Recollect facts about a user"]
  end

  def call(bot, args, message)
    user = args[1]
    values = KeyValue.get("Fubot:Whois:#{user}[]")
    if values.size > 0
      bot.reply "#{user} is: #{values.join(", ")}"
    else
      bot.reply "I don't know anything about #{user}."
    end
  end
end

Fubot.command /remember ([^ ]+) is (.+)/i do
  def help
    ["remember", "Remember a fact about a user"]
  end

  def call(bot, args, message)
    user = args[1]
    args[2].split(",").each do |title|
      KeyValue.set("Fubot:Whois:#{user}[]", "#{bot.user.id}:#{title.chomp}")
    end
    bot.reply "I'll remember this."
  end
end
