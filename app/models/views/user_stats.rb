module Views
  class UserStats < ApplicationView

    attrs :user

    fetches :posts_count, proc { Post.site_scope(site).where(user_id: user.id).count }
    fetches :channels_count, proc { Channel.site_scope(site).where(user_id: user.id).count }
    fetches :faves_count, proc { Fave.site_scope(site).where(user_id: user.id).count }
    fetches :faves_received, proc { Fave.site_scope(site).includes(:post).where("posts.user_id = ?", @user.id).references(:post).count }

    fetches :emojis, proc { Fave.user_emojis(site, user) }
    fetches :title, proc { KeyValue.site_scope(site).get("Fubot:Whois:#{user.login}[]") }

    fetches :last_posts, proc { @user.posts.site_scope(site).where("channels.default_read = ? AND channels.default_write = ?", true, true).limit(5).order("posts.created_at DESC").includes(:channel).references(:channel) }
    fetches :last_faves, proc { @user.faves.site_scope(site).includes(:post).order("faves.created_at DESC").limit(5) }

  end
end
