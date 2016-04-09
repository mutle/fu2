Fubot.command /emojis/i do
  def help
    ["emojis", "List custom emojis"]
  end

  def call(bot, args, message)
    emojis = CustomEmoji.all.map { |e| [e.name.downcase, ":#{e.name.downcase}:", e.url].join(" ") }.join("\n")
    bot.reply "All custom emojis: \n\n#{emojis}"
  end
end

Fubot.command /emoji ([^ ]+) at ([^ ]+)/i do
  def help
    ["emoji", "Create a new emoji with url"]
  end

  def call(bot, args, message)
    name = args[1].downcase
    url = args[2]
    begin
      uri = URI.parse(url)
      raise URI::InvalidURIError if uri.scheme != "http" && uri.scheme != "https"
    rescue URI::InvalidURIError => e
      bot.reply "This is not a valid http(s) URL: #{url}"
      return
    end
    emoji = CustomEmoji.where(name: name).first
    if emoji
      if emoji.user_id == bot.user.id
        emoji.update_attribute(:url, url)
        bot.reply "Updated emoji :#{name}: with #{url}."
      else
        bot.reply "You can't update emojis created by #{emoji.user.login}."
      end
    else
      CustomEmoji.create(name: name, url: url, user_id: bot.user.id, site_id: bot.site.id)
      bot.reply "Created emoji :#{name}: at #{url}."
    end
  end
end
