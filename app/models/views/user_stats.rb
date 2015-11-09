module Views
  class UserStats < ApplicationView

    attrs :user

    fetches :posts_count, proc { Post.where(user_id: user.id).count }
    fetches :channels_count, proc { Channel.where(user_id: user.id).count }
    fetches :faves_count, proc { Fave.where(user_id: user.id).count }
    fetches :faves_received, proc { Fave.includes(:post).where("posts.user_id = ?", @user.id).references(:post).count }

    fetches :emojis, proc { Fave.user_emojis(user) }
    fetches :title, proc { KeyValue.get("Fubot:Whois:#{user.login}[]") }

    fetches :last_posts, proc { @user.posts.where("channels.default_read = ? AND channels.default_write = ?", true, true).limit(5).order("posts.created_at DESC").includes(:channel).references(:channel) }
    fetches :last_faves, proc { @user.faves.includes(:post).order("faves.created_at DESC").limit(5) }

  end
end
