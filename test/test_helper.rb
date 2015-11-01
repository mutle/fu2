ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require "capybara/rails"

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: false, inspector: true, phantomjs: Phantomjs.path)
end
Capybara.javascript_driver = :poltergeist

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    $redis.flushdb
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
  self.use_transactional_fixtures = true

  def login(login, password)
    post("/session", login: login, password: password)
  end

  def login_user
    u = @user || create_user
    login u.login, "testpassword"
    u
  end

  def json_body
    JSON.parse response.body
  end
end

class JSTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  self.use_transactional_fixtures = false
  Poltergeist = Capybara::Session.new(:poltergeist, Fu2::Application)

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    @session = Poltergeist
  end

  def session_url(path)
   server = @session.server
   "http://#{server.host}:#{server.port}#{path}"
  end

  def login(login, password)
    visit session_url("/session/new")
    fill_in "Username", with: login
    fill_in "Password", with: password
    find_button("Login").click
  end
end
