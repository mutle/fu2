module Views
  class CurrentUserView < ApplicationView

    attrs :current_user

    fetches :unread_messages, proc { Notification.for_user(current_user).messages.unread.count }
    fetches :unread_mentions, proc { Notification.for_user(current_user).mentions.unread.count }
    fetches :counters, proc { {messages: unread_messages, mentions: unread_mentions} }, [:unread_messages, :unread_mentions]

  end
end
