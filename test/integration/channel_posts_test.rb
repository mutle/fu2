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
end
