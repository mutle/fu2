require 'test_helper'

class ChannelPostsEventsTest < JSTest

  setup do
    create_user
    create_channel
    login_user
  end

  test "show rename event" do
    @channel.events.create(event: "rename", data: {old_title: "OLD", title: "NEW"}, user_id: @user.id)
    visit session_url("/channels/#{@channel.id}")
    p has_selector?(".event")
    page.save_screenshot
  end
end
