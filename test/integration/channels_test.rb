require 'test_helper'

class ChannelsTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  test "list channels" do
    c = create_channel("Foo Channel")
    get '/'
    assert_select "li a", :text => "Foo Channel"
  end

  test "list channels live update" do
    c = create_channel("Foo Channel")
    l = c.last_post_id
    get '/channels/live', {last_id: l}
    assert_equal "", response.body

    c = create_channel("Bar Channel")
    get '/channels/live', {last_id: l}
    assert_select "li a", :text => "Bar Channel"
    assert_select "li a", :text => "Foo Channel"
  end

end
