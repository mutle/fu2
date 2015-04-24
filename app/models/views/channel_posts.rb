module Views
  class ChannelPosts < ApplicationView

    attrs :current_user, :channel, :last_read_id, :first_id, :last_id, :limit, :last_update

    fetches :post_count, proc { channel.posts.count }
    fetches :posts, proc {
      p = if first_id
        Post.before(channel, first_id)
      elsif last_id
        Post.since(channel, last_id)
      end

      if p
        p = p.includes(:user, :faves)
        if limit
          p = p.order("id desc").limit(limit.to_i).reverse
        else
          p = p.order("id")
        end
      end

      posts = p || channel.show_posts(current_user, last_read_id)
      posts.each do |p|
        p.channel = channel
      end
      posts
    }
    fetches :updated_posts, proc { last_update ? Post.updated_since(channel, last_update) : [] }
    fetches :last_update, proc { (posts.map(&:created_at) + posts.map(&:updated_at) + updated_posts.map(&:updated_at)).map(&:utc).max.to_i }, [:posts, :updated_posts]
    fetches :updated_by_user, proc { channel.updated_by_user }

  end
end
