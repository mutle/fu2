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

  test "list channels json" do
    c = create_channel("Foo Channel")
    get '/channels.json'
    j = json_body
    jc = j['channels'].first
    assert_equal c.id, jc['id']
    assert_equal c.title, jc['title']
    assert_equal false, jc['read']

    c.visit(@user)
    get '/channels.json'
    jc = json_body['channels'].first
    assert_equal true, jc['read']
  end

  test "create channel and post" do
    post '/channels.json', {channel: {title: "Test Channel", body: "Testing"}}
    get '/channels.json'
    j = json_body
    jc = j['channels'].first
    assert_not_nil jc['id']
    assert_equal "Test Channel", jc['title']
    assert_equal true, jc['read']
  end

  # test "list channels live update" do
  #   c = create_channel("Foo Channel")
  #   l = c.last_post_id
  #   get '/channels/live', {last_id: l}
  #   assert_equal "", response.body
  #
  #   c = create_channel("Bar Channel")
  #   get '/channels/live', {last_id: l}
  #   assert_select "li a", :text => "Bar Channel"
  #   assert_select "li a", :text => "Foo Channel"
  # end
  #
  # test "list links to first new post in channel" do
  #   c = create_channel("Foo Channel")
  #   p1 = create_post("P1")
  #   p2 = create_post("P2")
  #   p3 = create_post("P3")
  #   c.visit(@user, p1.id)
  #   get '/'
  #   assert_select "li a[href='/channels/#{c.id}#read_#{p1.id}']", :text => "Foo Channel"
  #
  #   c.visit(@user, p2.id)
  #   get '/'
  #   assert_select "li a[href='/channels/#{c.id}#read_#{p2.id}']", :text => "Foo Channel"
  #
  #   c.visit(@user, p3.id)
  #   get '/'
  #   assert_select "li a[href='/channels/#{c.id}#comments']", :text => "Foo Channel"
  # end
  #
  #
  # test "show channel" do
  #   c = create_channel("Foo Channel")
  #   create_post("**bold**\n")
  #   get "/channels/#{c.id}"
  #   assert_select "h2 .title-text", :text => "Foo Channel"
  #   assert_select ".channel-post .body strong", :text => "bold"
  # end
  #
  # test "show channel events" do
  #   c = create_channel("Foo Channel")
  #   c.rename("Bar Channel", @user)
  #   c.save
  #   create_post("post\n")
  #   get "/channels/#{c.id}"
  #   assert_select "h2 .title-text", :text => "Bar Channel"
  #   assert_select ".event.rename"
  # end

end
