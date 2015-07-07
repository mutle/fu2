module Views
  class ChannelPosts < ListView

    attrs :current_user, :channel, :last_read_id, :first_id, :last_id, :limit, :last_update

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
        p.read = !(last_read_id && p.id > last_read_id)
      end
      posts
    }
    fetches :updated_posts, proc { last_update ? Post.updated_since(channel, last_update) : [] }
    fetches :last_update, proc { (posts.map(&:created_at) + posts.map(&:updated_at) + updated_posts.map(&:updated_at)).map(&:utc).max.to_i }, [:posts, :updated_posts]

    fetches :count, proc { channel.posts.count }
    fetches :start_index, proc { 0 }
    fetches :end_index, proc { posts.size }, [:posts]

  end
end
