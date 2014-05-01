module RollDice
  class << self
    def roll(dice, sides)
      res = []
      dice.times do
        res.push rand(sides).to_i + 1
      end
      res
    end

    def response(dice, sides)
      "I rolled #{roll(dice,sides).join(", ")}"
    end
  end
end

Fubot.command /roll (\d+)[dw](\d+)/ do
  def help
    ["roll XdY", "Rolls X dices with Y faces"]
  end

  def call(bot, args, message)
    bot.reply RollDice.response(args[1].to_i, args[2].to_i)
  end
end

Fubot.command /roll( dice)?/ do
  def help
    ["roll dice", "Rolls a single dice"]
  end

  def call(bot, args, message)
    bot.reply RollDice.response(1, 6)
  end
end
