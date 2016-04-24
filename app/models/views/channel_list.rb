module Views
  class ChannelList < ListView

    attrs :current_user, :last_update_date, :query, :tag

    fetches :filter_ids, proc { Channel.filter_ids(site, query, tag, current_user) }
    fetches :recent_channels, proc { Channel.recent_channels(site, current_user, page, per_page, last_update_date, filter_ids) }, [:filter_ids]
    fetches :highlight_query, proc {
      recent_channels.each { |channel| channel.query = query }
      nil
    }, [:recent_channels]
    fetches :last_post, proc {
      Channel.last_posts(recent_channels, current_user)
      nil
    }, [:recent_channels]
    fetches :count, proc { recent_channels.count }, [:recent_channels]
    fetches :start_index, proc { (page - 1) * per_page }
    fetches :end_index, proc { (page - 1) * per_page + recent_channels.size }, [:recent_channels]
    fetches :last_update, proc { (recent_channels.map(&:created_at) + recent_channels.map(&:updated_at) + recent_channels.map(&:last_post_date)).map(&:utc).max.to_i }, [:recent_channels]
    fetches :type, proc { filter_ids && !tag && filter_ids.size > 0 ? "channel-filtered" : "channel" }, [:filter_ids]
  end
end
