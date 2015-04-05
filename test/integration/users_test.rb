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

  test "show users json" do
    u = create_user
    get "/users.json"
    ju = json_body['users'].last
    assert_equal u.id, ju['id']
    assert_equal u.login, ju['login']
  end

end
