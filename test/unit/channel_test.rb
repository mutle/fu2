require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  def create_channel(title=nil, body=nil)
    Channel.create(:user_id => 1, :title => title || "test c #{Time.now.to_f}", :body => body)
  end

  test "create first post" do
    c = create_channel("foo", "bar")
    assert_equal 1, c.posts.size
  end

  test "create post with empty body" do
    c = create_channel("foo")
    assert_equal 1, c.posts.size
  end

  test "visit clears mentions" do
    u = create_user
    c = create_channel("foo", "bar")
    c.add_mention(u)
    assert_equal 1, c.num_mentions(u)
    c.visit(u)
    assert_equal 0, c.num_mentions(u)
  end

  test "unread posts" do
    u = create_user
    c = create_channel("foo", "bar")
    assert c.has_posts?(u)
    c.visit(u)
    assert !c.has_posts?(u)
  end

  test "merge channels" do
    u = create_user
    c = create_channel("foo", "bar")
    c2 = create_channel("foo 2", "baz")
    @channel = c
    create_post("foo")
    old_id = c2.id
    c.merge(c2, u)
    assert_raise(ActiveRecord::RecordNotFound) { Channel.find(c2.id) }
    assert_equal 3, c.posts.count
    assert_equal "foo", c.posts.all[0].body
    assert_equal "baz", c.posts.all[1].body
    assert_equal "bar", c.posts.all[2].body
    assert_equal 1, c.events.where(event: "merge").size
    assert_equal c.id, ChannelRedirect.from_id(old_id).target_channel_id
  end

  test "next post" do
    u = create_user
    c = create_channel
    @channel = c
    p1 = create_post("p1")
    p2 = create_post("p2")
    p3 = create_post("p3")
    c.visit(u, p1.id)
    assert_equal p2.id, c.next_post(u)
    c.visit(u, p2.id)
    assert_equal p3.id, c.next_post(u)
    c.visit(u, p3.id)
    assert c.next_post(u) > p3.id
  end
end
