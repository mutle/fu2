ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'

class ActiveSupport::TestCase
  setup do
    User.stubs(:fubot).returns(User.new)
  end

  def create_user(login=nil, password="testpassword", activate=true)
    u = User.create({
      login: login || "testuser#{Time.now.to_f.to_s.gsub(/\./, '')}",
      password: password,
      password_confirmation: password,
      email: "user-#{Random.rand(1000)}@example.com",
      markdown: true
    })
    if activate
      u.activated_at = Time.now
      u.save
    end
    @user ||= u
    u
  end

  def create_channel(title=nil, body=nil)
    c = Channel.create(title: title || "test c #{Time.now.to_f}", body: body, user: @user)
    @channel ||= c
    c
  end

  def create_post(body="post")
    @channel ||= create_channel
    @channel.posts.create(user: @user, body: body, markdown: true)
  end
end

class ActionDispatch::IntegrationTest
  def login(login, password)
    post("/session", login: login, password: password)
  end

  def login_user
    u = create_user "testuser", "testpw"
    login "testuser", "testpw"
    u
  end

  def json_body
    JSON.parse response.body
  end
end
