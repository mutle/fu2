Fubot.command /deployed\?/ do
  def help
    ["deployed", "Shows the currently deployed commit"]
  end

  def call(bot, args, message)
    info = `git show --oneline -s`.split(" ", 2)
    bot.reply "[#{info.first}](https://github.com/mutle/fu2/commit/#{info.first}) #{info.last}"
  end
end

Fubot.command /deploy ?([^ ]*)/ do
  DEPLOY_USERS = ["mutle"]
  DEPLOY_SCRIPT = proc { |branch| "/bin/bash -c \"/data/fu2/current/bin/deploy #{branch} 2>&1\"" }

  def help
    ["deploy [branch]", "Deploys the redcursor app"]
  end

  def call(bot, args, message)
    branch = args[1]
    branch = "master" if branch.blank?
    if !DEPLOY_USERS.include?(bot.user.login)
      bot.reply "You are not allowed to deploy."
    else
      bot.reply "Deploys via Fubot are temporarily disabled."
      # bot.reply "Deploying #{branch} to production."
      # script = DEPLOY_SCRIPT.call(branch)
      # result = `#{script}`
      # bot.reply "```\n#{result}\n```"
      # bot.reply "Deploy completed."
    end
  end
end
