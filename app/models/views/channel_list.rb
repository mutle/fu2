module Views
  class ChannelList < ApplicationView

    attrs :current_user, :page

    fetches :recently_active, proc { Channel.recently_active(current_user) }
    fetches :recent_channels, proc { Channel.recent_channels(current_user, page) }
    fetches :recent_posts, proc { Channel.recent_posts(recent_channels) }, [:recent_channels]
    fetches :channel_count, proc { Channel.count }

  end
end
