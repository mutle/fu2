require 'test_helper'

class LoginTest < ActionController::IntegrationTest

  def setup
    User.delete_all
  end

  test "login required" do
    visit '/'
    assert current_path =~ /session/
  end

  test "login page" do
    visit '/session/new'
    assert response.ok?
  end

  test "login with invalid user name" do
    login("testuser", "testpw")
    assert response.ok?
    assert has_css?(".notice", :text => "Login or Password incorrect!" )
  end

  test "login with incorrect password" do
    create_user "testuser", "nottestpw"
    login("testuser", "testpw")
    assert response.ok?
    assert has_css?(".notice", :text => "Login or Password incorrect!" )
  end

  test "login with inactive account" do
    create_user "testuser", "testpw", false
    login("testuser", "testpw")
    assert response.ok?
    assert has_css?(".notice", :text => "Login or Password incorrect!" )
  end

  test "successful login" do
    create_user "testuser", "testpw"
    login("testuser", "testpw")
    p body
    p current_url
    assert response.ok?
    assert has_css?(".notice", :text => "Logged in successfully")
  end
end
