require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest

  def setup
    User.delete_all
  end

  def assert_password_incorrect
    assert_response :success
    assert_select(".notice", :text => "Login or Password incorrect!" )
  end

  test "redirect to login page when unauthorized" do
    get '/'
    assert_redirected_to("/session/new")
  end

  test "get login page" do
    get '/session/new'
    assert_response :success
  end

  test "login fails with invalid user name" do
    login("testuser", "testpw")
    assert_password_incorrect
  end

  test "login fails with incorrect password" do
    create_user "testuser", "nottestpw"
    login("testuser", "testpw")
    assert_password_incorrect
  end

  test "login fails with inactive account" do
    create_user "testuser", "testpw", false
    login("testuser", "testpw")
    assert_password_incorrect
  end

  test "successful login redirects to root" do
    create_user "testuser", "testpw"
    login("testuser", "testpw")
    assert_redirected_to("/")
  end
end
