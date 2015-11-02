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
    login("testuser-#{Time.now.to_f.to_s.gsub(/\./, '')}", "testpw")
    assert_password_incorrect
  end

  test "login fails with incorrect password" do
    l = "testuser-#{Time.now.to_f.to_s.gsub(/\./, '')}"
    create_user l, "nottestpw"
    login(l, "testpw")
    assert_password_incorrect
  end

  test "login fails with inactive account" do
    l = "testuser-#{Time.now.to_f.to_s.gsub(/\./, '')}"
    create_user l, "testpw", false
    login(l, "testpw")
    assert_password_incorrect
  end

  test "successful login redirects to root" do
    l = "testuser-#{Time.now.to_f.to_s.gsub(/\./, '')}"
    create_user l, "testpw"
    login(l, "testpw")
    assert_redirected_to("/")
  end
end
