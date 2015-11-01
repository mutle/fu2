require 'test_helper'

class ChannelPostsTest < JSTest

  setup do
    create_user
    create_channel
    login_user
  end

  test "visit channel" do
    visit session_url("/channels/#{@channel.id}")
    assert has_selector?(".channel-post .body", text: "... has nothing to say")
  end

  test "comment in channel" do
    visit session_url("/channels/#{@channel.id}")
    assert page.has_no_selector?(".channel-post .body", text: "Test Comment")
    find("textarea.comment-box").set("Test Comment")
    find_button("Send").click
    assert page.has_selector?("textarea.comment-box", text: "")
    assert page.has_selector?(".channel-post .body", text: "Test Comment")
  end

  test "update comment" do
    post = create_post
    visit session_url("/channels/#{@channel.id}")
    assert page.has_no_selector?(".channel-post .body", text: "Updated Comment")
    find(".channel-post.post-#{post.id} .post-edit").click
    find(".channel-post.post-#{post.id} .channel-edit textarea.comment-box").set("Updated Comment")
    find(".channel-post.post-#{post.id} .channel-edit .button-default").click
    page.has_selector?(".channel-post .body", text: "Updated Comment")
    assert page.has_selector?(".channel-post .body", text: "Updated Comment")
  end

end
