require 'test_helper'

class ChannelPostsFaceCounterTest < JSTest

  setup do
    create_user
    create_channel
    login_user
  end

  test "fave star" do
    visit session_url("/channels/#{@channel.id}")
    post = @channel.posts.first.id
    assert page.has_selector?(".channel-post.post-#{post} .faves")
    assert page.has_selector?(".channel-post.post-#{post} .faves button.emoji-star", text: "0")
    page.find(".channel-post.post-#{post} .faves button.emoji-star").click
    assert page.has_selector?(".channel-post.post-#{post} .faves button.emoji-star.on", text: "1")
    page.find(".channel-post.post-#{post} .faves button.emoji-star").click
    assert page.has_selector?(".channel-post.post-#{post} .faves button.emoji-star", text: "0")
  end

  test "fave emoji" do
    visit session_url("/channels/#{@channel.id}")
    post = @channel.posts.first.id
    assert page.has_no_selector?(".channel-post.post-#{post} .faves button.emoji-abcd")
    page.find(".channel-post.post-#{post} .faves button.add-emoji-button").click
    page.find(".channel-post.post-#{post} .faves .add-emoji .autocompleter li:last-child").click
    assert page.has_selector?(".channel-post.post-#{post} .faves button.emoji-abcd.on", text: "1")
    page.find(".channel-post.post-#{post} .faves button.emoji-abcd").click
    assert page.has_no_selector?(".channel-post.post-#{post} .faves button.emoji-abcd")
  end

  test "fave emoji completer" do
    visit session_url("/channels/#{@channel.id}")
    post = @channel.posts.first.id
    assert page.has_no_selector?(".channel-post.post-#{post} .faves button.emoji-heart")
    page.find(".channel-post.post-#{post} .faves button.add-emoji-button").click
    page.find(".channel-post.post-#{post} .faves .add-emoji input").native.send_keys("heart", :return)
    assert page.has_selector?(".channel-post.post-#{post} .faves button.emoji-heart.on", text: "1")
  end

end
