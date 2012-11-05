module ChannelsHelper
  
  def format_body(post)
    return auto_link(RDiscount.new(post.body).to_html, :sanitize => false).html_safe if post.markdown?
    text = simple_format(post.body, {}, :sanitize => false)
    if text.length < 64000
      text = auto_link(text, :sanitize => false)
    end
    text.html_safe
  end
  
  def user_link(user)
    return "" unless user
    link_to h(user.login), user_path(user), :style => user.display_color
  end
  
  def user_name(user)
    "&lt;".html_safe + user_link(user) + "&gt;".html_safe
  end
  
end
