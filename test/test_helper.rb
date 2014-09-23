ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  setup do
    User.stubs(:fubot).returns(User.new)
  end
end

class ActionController::IntegrationTest
  def create_user(login, password, activate=true)
    u = User.create(:login => login, :password => password, :password_confirmation => password, :email => "user-#{Random.rand(1000)}@example.com")
    if activate
      u.activated_at = Time.now
      u.save
    end
    u
  end

  def login(login, password)
    post("/session", :login => login, :password => password)
  end
end
