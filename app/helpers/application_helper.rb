module ApplicationHelper

  def users_js
    javascript_tag "window.Users = #{User.all.map { |u| u.as_json.merge({type: "user", avatar_url: u.avatar_image_url(32), avatar_url_full: u.avatar_image_url(128)}) }.to_json};"
  end

  def octicon(name, mega=false, klass="")
    content_tag :span, "", :class => "#{'mega-' if mega}octicon octicon-#{name} #{klass}"
  end

end
