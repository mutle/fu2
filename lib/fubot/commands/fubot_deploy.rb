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
  DEPLOY_SCRIPT = proc { |branch| "/bin/bash -c \". /data/fu2/shared/env && cd /data/fu2/current && git fetch origin && cp config/database.yml{,.bak} && git reset --hard origin/#{branch} && cp config/database.yml{.bak,} && bundle install >/dev/null && bundle exec rake assets:precompile && kill -HUP \`cat /data/fu2/shared/unicorn.pid\` && kill -HUP `cat /data/fu2/shared/resqued.pid`\"" }

  def help
    ["deploy [branch]", "Deploys the redcursor app"]
  end

  def call(bot, args, message)
    branch = args[1]
    branch = "master" if branch.blank?
    if !DEPLOY_USERS.include?(bot.user.login)
      bot.reply "You are not allowed to deploy."
    else
      bot.reply "Deploying #{branch} to production."
      script = DEPLOY_SCRIPT.call(branch)
      result = `#{script}`
      bot.reply "```\n#{result}\n```"
      bot.reply "Deploy completed."
    end
  end
end
