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

  test "new channel" do
    visit session_url("/channels/new")
    assert page.has_selector?(".channel-new")
    fill_in "Channel Title", with: "Test New Channel #{Time.now.to_f}"
    find(".channel-new textarea").set("Test Comment")
    find_button("Create").click
    assert page.has_selector?(".channel-post .body", text: "Test Comment")
  end

  # test "edit channel" do
  #   visit session_url("/channels/#{@channel.id}")
  #   p page.has_no_selector?(".channel-edit")
  #   p page.has_selector?("h2 a", text: @channel.title)
  #   page.save_screenshot
  #   find(".edit-channel-link").click
  #   p page.has_selector?(".channel-edit")
  #   new_title = "Update Channel #{Time.now.to_f}"
  #   fill_in "Channel Title", with: new_title
  #   fill_in "text", with: "Update text"
  #   find_button("Save").click
  #   p page.has_selector?(".channel-text .title-text", text: "Update text")
  #   p page.has_no_selector?(".channel-post .body", text: "Update text")
  #   p page.has_no_selector?("h2 a", text: @channel.title)
  #   p page.has_selector?("h2 a", text: new_title)
  #   page.save_screenshot
  # end

end
