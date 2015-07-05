module Views
  class ChannelList < ApplicationView

    attrs :current_user, :page

    fetches :recent_channels, proc { Channel.recent_channels(current_user, page) }
    fetches :channels_read, proc {
      recent_channels.each do |channel|
        channel.read = channel.has_posts?(current_user, channel.last_post)
      end
      nil
    }, [:recent_channels]
    fetches :channel_count, proc { Channel.count }

  end
end
