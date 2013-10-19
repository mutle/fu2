require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  def setup
    Channel.delete_all
  end

  def create_channel(title, body)
    Channel.create(:user_id => 1, :title => title, :body => body)
  end

  test "create first post" do
    c = create_channel("foo", "bar")
    assert_equal 1, c.posts.size
  end

  test "create post with empty body" do
    c = create_channel("foo", nil)
    assert_equal 1, c.posts.size
  end
end
