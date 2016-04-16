require 'test_helper'

class ApiPostsTest < ActionDispatch::IntegrationTest

  setup do
    stub_callbacks
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
    post "/api/channels/#{c.id}/posts.json", {post: {body: "Test"}}
    assert_equal "Test", json_body['post']['body']
    assert_not_nil json_body['post']['id']
    p = Channel.find(c.id).last_post
    assert_equal "Test", p.body
  end

  test "update post" do
    p = create_post
    assert_not_equal "Test", p.body
    patch "/api/channels/#{p.channel_id}/posts/#{p.id}.json", {post: {body: "Test"}}
    assert_equal "Test", json_body['post']['body']
    p.reload
    assert_equal "Test", p.body
  end

  test "destroy post" do
    p = create_post
    delete "/api/channels/#{p.channel_id}/posts/#{p.id}"
    assert json_body['post']['deleted']
    assert_raise(ActiveRecord::RecordNotFound) { Post.find(p.id) }
  end

  test "show posts json" do
    c = create_channel("Foo Channel #{Time.now.to_f}")
    p = create_post("Post")
    get "/api/channels/#{c.id}/posts.json"
    j = json_body
    jc = j['channel']
    assert_equal c.id, jc['id']
    jp = j['posts'].last
    assert_equal p.id, jp['id']
    assert_equal p.body, jp['body']
  end

  test "create post json" do
    c = create_channel
    assert_not_equal "Test", c.last_post.body
    post "/api/channels/#{c.id}/posts.json", {post: {body: "Test"}}
    jp = json_body['post']
    assert_equal "Test", jp['body']
    assert_not_nil jp['html_body']
  end

end
