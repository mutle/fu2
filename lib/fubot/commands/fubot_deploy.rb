Fubot.command /deploy ?([^ ]*)/ do
  DEPLOY_USERS = ["mutle"]
  DEPLOY_SCRIPT = proc { |branch| "/bin/bash -c \". /data/fu2/shared/env && cd /data/fu2/current && git fetch origin && cp config/database.yml{,.bak} && git reset --hard origin/#{branch} && cp config/database.yml{.bak,} && bundle install && bundle exec rake assets:precompile && kill -HUP \`cat /data/fu2/shared/unicorn.pid\`\"" }

  def help
    ["deploy", "Deploys the redcursor app"]
  end

  def call(bot, args, message)
    branch = args[1]
    branch = "master" if branch.blank?
    if !DEPLOY_USERS.include?(bot.user.login)
      bot.reply "You are not allowed to deploy."
    else
      bot.reply "Deploying #{branch} to production."
      bot.reply system(DEPLOY_SCRIPT.call(branch))
      bot.reply "Deploy completed."
    end
  end
end
