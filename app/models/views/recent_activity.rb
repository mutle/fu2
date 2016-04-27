module Views
  class RecentActivity < ApplicationView

    attrs :current_user, :timeframe

    fetches :posts, proc { Post.site_scope(site).timeframe(timeframe).includes(:faves) }
    fetches :active_channels, proc { Post.active_channels(posts) }, [:posts]
    fetches :active_users, proc {
      active = {}
      posts.map(&:user_id).each do |uid|
        active[uid] ||= 0
        active[uid] += 1
      end
      active
    }, [:posts]
    fetches :active_emojis, proc {
      active = {}
      posts.map {|p| p.faves.to_a }.flatten.map(&:emoji).each do |fave|
        active[fave] ||= 0
        active[fave] += 1
      end
      active
    }, [:posts]
    fetches :last_posts, proc { Channel.last_posts(active_channels, current_user); nil }, [:posts, :active_channels]
    fetches :best_posts, proc { Post.best_posts(posts) }, [:posts]

  end
end
