Fubot.command /help/ do
  def help
    ["help", "This command"]
  end

  def call(bot, args, message)
    resp = "All Fubot commands:\n\n"
    Fubot.commands.each do |pattern,command|
      c = command.new.help
      resp << "/#{c[0]} - #{c[1]}\n"
    end
    bot.reply resp
  end
end
