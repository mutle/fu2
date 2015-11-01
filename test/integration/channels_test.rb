require 'test_helper'

class ChannelsTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  test "redirect merged channel" do
    ChannelRedirect.create(original_channel_id: 100, target_channel_id: 1)
    get "/channels/100"
    assert_redirected_to "/channels/1"
  end
end
