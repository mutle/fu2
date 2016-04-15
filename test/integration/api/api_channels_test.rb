require 'test_helper'

class ApiChannelsTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  test "list channels json" do
    title = "Foo Channel #{Time.now.to_f}"
    c = create_channel(title)
    get '/api/channels.json'
    j = json_body
    puts j.inspect
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
    title = "Test Channel #{Time.now.to_f}"
    post '/api/channels.json', {channel: {title: title, body: "Testing"}}
    j = json_body
    puts j.inspect
    assert_nil json_body['errors']
    jc = j['channel']
    assert_not_nil jc['id']
    assert_equal title, jc['title']
    assert_equal true, jc['read']
  end

  test "create channel requires unique name" do
    title = "Title in use #{Time.now.to_f}"
    c = create_channel(title)
    post '/api/channels.json', {channel: {title: title, body: "Testing"}}
    assert_not_nil json_body['errors']['title']
  end

  test "update channel title and text" do
    title = "Foo Channel #{Time.now.to_f}"
    c = create_channel(title)
    title2 = "FooTest Channel #{Time.now.to_f}"
    put "/api/channels/#{c.id}.json", {channel: {title: title2, text: "Channel text"}}
    j = json_body
    puts j.inspect
    jc = j['channel']
    assert_equal title2, jc['title']
    assert_equal "Channel text", jc['text']
  end
end
