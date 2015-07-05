class Live
  class << self
    def context
      @context ||= ActionController::Renderer.for(ApplicationController)
    end

    def update(type, object, template, user_id=0)
      object_data = JbuilderTemplate.encode(context) do |json|
        json.type type
        json.user_id user_id
        json.object do
          json.partial! "shared/#{template}", template.to_sym => object
        end
      end
      $redis.publish 'live', object_data
    end

    def post_create(post)
      update :post_create, post, "post"
    end

    def post_update(post)
      update :post_update, post, "post"
    end

    def posts_read(channel, user)
      update :posts_read, channel, "channel", user.id
    end

    def post_destroy(post)
      update :post_destroy, post, "post"
    end

    def post_fave(post)
      update :post_fave, post, "post"
    end

    def post_unfave(post)
      update :post_unfave, post, "post"
    end

    def channel_create(channel)
      update :channel_create, channel, "channel"
    end

    def channel_update(channel)
      update :channel_update, channel, "channel"
    end

    def notification_counters(user)
      view = Views::CurrentUserView.new({current_user: user})
      view.finalize
      update :counters, view, "counters", user.id
    end
  end
end
