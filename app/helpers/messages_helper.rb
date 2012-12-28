module MessagesHelper
  
  def message_user_link(user)
    link_to h(user.display_name), new_message_path(:receiver_name => user.login) rescue "Deleted User"
  end
  
  def format_message_body(message)
    text = sanitize(message)
    text = simple_format(text)
    text = auto_link(text)
    return text
  end
  
end
