module ChannelsHelper
  
  def format_body(post)
    text = simple_format(post.body)
    text = auto_link(text)
  end
  
  def user_link(user)
    link_to h(user.display_name), user_path(user), :style => user.display_color
  end
  
  def user_name(user)
    "&lt;#{user_link(user)}&gt;"
  end
  
end
