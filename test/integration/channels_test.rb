require 'test_helper'

class ChannelsTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  def json_body
    JSON.parse response.body
  end

  test "list channels" do
    c = create_channel("Foo Channel")
    get '/channels'
    assert_response 200
  end

  test "show channel" do
    c = create_channel("Foo Channel")
    get "/channels/#{c.id}"
    assert_response 200
  end

  test "redirect merged channel" do
    ChannelRedirect.create(original_channel_id: 100, target_channel_id: 1)
    get "/channels/100"
    assert_redirected_to "/channels/1"
  end
end
