module ApplicationHelper

  def users_js
    javascript_tag "window.Users = #{User.all.map { |u| {:login => u.login, :id => u.id, :avatar_url => u.avatar_image_url(22) } }.to_json};"
  end

end
