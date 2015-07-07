require 'test_helper'

class ApiChannelsTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  test "list channels json" do
    c = create_channel("Foo Channel")
    get '/api/channels.json'
    j = json_body
    jc = j['channels'].first
    assert_equal c.id, jc['id']
    assert_equal c.title, jc['title']
    assert_equal false, jc['read']

    c.visit(@user)
    get '/api/channels.json'
    jc = json_body['channels'].first
    assert_equal true, jc['read']
  end

  test "create channel and post" do
    post '/api/channels.json', {channel: {title: "Test Channel", body: "Testing"}}
    j = json_body
    assert_nil json_body['errors']
    jc = j['channel']
    assert_not_nil jc['id']
    assert_equal "Test Channel", jc['title']
    assert_equal true, jc['read']
  end

  test "create channel requires unique name" do
    c = create_channel("Title in use")
    post '/api/channels.json', {channel: {title: "Title in use", body: "Testing"}}
    assert_not_nil json_body['errors']['title']
  end

  test "update channel title and text" do
    c = create_channel("Foo Channel")
    put "/api/channels/#{c.id}.json", {channel: {title: "Test Channel", text: "Channel text"}}
    j = json_body
    jc = j['channel']
    assert_equal "Test Channel", jc['title']
    assert_equal "Channel text", jc['text']
  end
end
