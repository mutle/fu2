module Views
  class ChannelList < ApplicationView

    attrs :current_user, :site, :page

    fetches :recently_active, proc { Channel.recently_active(site, current_user) }
    fetches :recent_channels, proc { Channel.recent_channels(site, current_user, page) }
    fetches :recent_posts, proc { Channel.recent_posts(recent_channels) }, [:recent_channels]

  end
end
