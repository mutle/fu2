require 'test_helper'

class ChannelPostsTextTest < JSTest

  setup do
    create_user
    create_channel
    login_user
  end

  test "show channel text" do
    @channel.text = "Lorem ipsum"
    @channel.save
    visit session_url("/channels/#{@channel.id}")
    assert page.has_selector?(".channel-text .body", text: "Lorem ipsum")
  end

end
