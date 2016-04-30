require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  test "notification on at-mention in post" do
    u = create_user
    @user = create_user
    assert_equal 0, Notification.for_user(u).mentions.count
    create_post("@#{u.login} hi!")
    assert_equal 1, Notification.for_user(u).mentions.count
    create_post("@#{u.login.upcase} hi!")
    assert_equal 2, Notification.for_user(u).mentions.count
  end

end
