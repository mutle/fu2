require 'test_helper'

class PostsTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  test "show posts with last update" do
  end

  test "show posts before first id" do
  end

  test "show posts since last id" do
  end

  test "create post" do
    c = create_channel
    assert_not_equal "Test", c.last_post.body
    post "/channels/#{c.id}/posts", {post: {body: "Test"}}
    p = Channel.find(c.id).last_post
    assert_redirected_to "/channels/#{c.id}#post_#{p.id}"
    assert_equal "Test", p.body
  end

  test "update post" do
    p = create_post
    assert_not_equal "Test", p.body
    patch "/channels/#{p.channel_id}/posts/#{p.id}", {post: {body: "Test"}}
    assert_redirected_to "/channels/#{p.channel_id}#post_#{p.id}"
    p.reload
    assert_equal "Test", p.body
  end

  test "destroy post" do
    p = create_post
    delete "/channels/#{p.channel_id}/posts/#{p.id}"
    assert_redirected_to "/channels/#{p.channel_id}"
    assert_raise(ActiveRecord::RecordNotFound) { Post.find(p.id) }
  end

end
