module Views
  class ChannelMerge < ApplicationView

    attrs :current_user, :channel

    fetches :similar, proc {
      s = ::Search.more_like_this("channels", "title", "channel", channel.id)
      p s
      s["hits"]["hits"].map do |h|
        p h
        begin
          h['channel'] = Channel.find(h['_id'].to_i)
        rescue
        end
        h
      end
    }

  end
end
