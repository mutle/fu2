module ChannelsHelper

  def format_body(post, highlight=nil)
    body = post.body
    if highlight
      body = highlight.split(" ").inject(body) { |s,q| s = highlight(s, q) }
    end
    result = post.markdown? ? RenderPipeline.markdown(body) : RenderPipeline.simple(body)
    return result.html_safe
  end

  def format_text(text)
    result = RenderPipeline.markdown(text)
    return result.html_safe
  end

  def format_date(date)
    t = (Time.now - date).to_i
    return "#{t}s" if t < 60
    t = (t / 60).to_i
    return "#{t}m" if t < 60
    t = (t / 60).to_i
    return "#{t}h" if t < 24
    t = (t / 24).to_i
    return "#{t}d" if t < 30
    t = (t / 365).to_i
    return "#{t}y"
  end

  def user_link(user)
    return "" unless user
    link_to format_title(user.display_name), user_path(user), :style => user.display_color
  end

  def user_name(user)
    user_link(user)
  end

  def format_title(channel)
    RenderPipeline.title(channel.is_a?(String) ? channel : channel.title).gsub(/<\/?div>/,'').html_safe
  end

  def format_event(event)
    RenderPipeline.markdown(event.event_message).gsub(/<\/?p>/,'').html_safe
  end

  def avatar_url(user, size=42)
    user.avatar_image_url(size)
  end

  def channel_anchor(channel, current_user, last_post)
    id = channel.last_read_id(current_user)
    if last_post && id >= last_post.id
      "comments"
    elsif id > 0
      "read_#{id}"
    else
      ""
    end
  end

  def channel_post_anchor(channel, post)
    "post_#{post.id}"
  end

  TS_ROUND_PRECISION = 10.0 * 60
  def rounded_timestamp(t)
    Time.at((t.to_i / TS_ROUND_PRECISION).ceil * TS_ROUND_PRECISION.to_i).strftime(Fu2.time_format)
  end

end
