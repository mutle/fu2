require 'test_helper'

class ChannelListTest < JSTest

  setup do
    create_user
    create_channel
    login_user
  end

  test "list current channels" do
    visit session_url("/")
    click_link(@channel.title)
    assert has_selector?(".channel-post .body", text: "... has nothing to say")
  end
end
