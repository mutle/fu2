require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  test "show other user" do
    u = create_user
    get "/users/#{u.id}"
    assert_select "a", u.login
  end

end
