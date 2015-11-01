require 'test_helper'

class ChannelListTest < JSTest

  setup do
    create_user
    create_channel
    login_user
  end

  test "list current channels" do
    visit session_url("/")
    find_link(@channel.title)
  end
end
