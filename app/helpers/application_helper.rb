module ApplicationHelper

  def users_js
    javascript_tag "window.Users = #{User.all.map { |u| {:login => u.login, :id => u.id, :avatar_url => u.avatar_image_url(22) } }.to_json};"
  end

  def octicon(name, mega=false)
    content_tag :span, "", :class => "#{'mega-' if mega}octicon octicon-#{name}"
  end

  def activity_hours(posts)
    num_hours = 12
    t = Time.now
    activity = Array.new(num_hours, 0)
    posts.each do |post|
      hour = (t - post.created_at) / 3600
      activity[hour] += 1 if hour < num_hours
    end
    activity.reverse
  end

end
