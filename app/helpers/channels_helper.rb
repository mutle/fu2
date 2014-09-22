module ChannelsHelper

  def format_body(post)
    result = post.markdown? ? RenderPipeline.markdown(post.body) : RenderPipeline.simple(post.body)
    return result.html_safe
  end

  def format_text(text)
    result = RenderPipeline.markdown(text)
    return result.html_safe
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

  def avatar_url(user, size=42)
    user.avatar_image_url(size)
  end

  def channel_anchor(channel, current_user, last_post)
    id = channel.next_post(current_user)
    if id > 0
      if id == last_post.id
        "comments"
      else
        "post_#{id}"
      end
    else
      ""
    end
  end

end
