class Live
  class << self
    def update(type, object, user_id=0)
      $redis.publish 'live', {:type => type, :user_id => user_id, :object => object.as_json}.to_json
    end

    def post_create(post)
      update :post_create, post
    end

    def post_update(post)
      update :post_update, post
    end

    def post_destroy(post)
      update :post_destroy, post
    end

    def post_fave(post)
      update :post_fave, post
    end

    def post_unfave(post)
      update :post_unfave, post
    end

    def channel_create(channel)
      update :channel_create, channel
    end

    def notification_counters(user)
      view = Views::CurrentUserView.new({current_user: user})
      view.finalize
      update :counters, view.counters, user.id
    end
  end
end
