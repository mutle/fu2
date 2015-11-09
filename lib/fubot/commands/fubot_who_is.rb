Fubot.command /who is @?([^ ]+)\??/i do
  def help
    ["who is", "Recollect facts about a user"]
  end

  def call(bot, args, message)
    user = args[1]
    values = KeyValue.get("Fubot:Whois:#{user}[]")
    if values.size > 0
      t = values.map { |v| m = v.split(":", 2); "#{m[1]} -- #{User.find(m[0].to_i).login}" }.join(", ")
      bot.reply "#{user} is: #{t}"
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
