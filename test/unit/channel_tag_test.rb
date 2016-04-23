require 'test_helper'

class ChannelTagTest < ActiveSupport::TestCase
  test "creating post with hash tags creates ChannelTag" do
    create_user
    c = create_channel
    assert_equal 0, c.channel_tags.count
    p = create_post("blah blah #winning. blah!")
    assert_equal 1, c.channel_tags.count
    assert_equal "winning", c.channel_tags.first.tag
    p.body = "#losing"
    p.save
    assert_equal 1, c.channel_tags.count
    assert_equal "losing", c.channel_tags.first.tag
  end

  test "find all unique tags" do
    create_user
    create_post("blah blah #winning. blah!")
    create_post("blah blah #winning. blah!")
    create_post("blah blah #losing. blah!")
    all = ChannelTag.all_tags(@site)
    assert all.include?("winning")
    assert all.include?("losing")
  end

  test "find channel ids for tag" do
    create_user
    create_post("blah blah #winning. blah!")
    channel_ids = ChannelTag.channel_ids(@site, "winning")
    assert_equal [@channel.id], channel_ids
  end
end
