module ApplicationHelper

  def users_js
    javascript_tag "window.Users = #{User.all.map { |u| {type: "user", login: u.login, id: u.id, avatar_url: u.avatar_image_url(32), display_name: format_title(u.display_name) } }.to_json};"
  end

  def octicon(name, mega=false, klass="")
    content_tag :span, "", :class => "#{'mega-' if mega}octicon octicon-#{name} #{klass}"
  end

end
