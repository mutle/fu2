require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest

  setup do
    Site.destroy_all
    login_user
  end

  test "root site api" do
    assert_raise(ActionController::RoutingError) { get "/api/info" }
    site = Site.create(path: "")
    assert_nothing_raised { get "/api/info" }
    assert_redirected_to "/session/new"
    SiteUser.create(site: site, user: @user)
    assert_nothing_raised { get "/api/info" }
    assert_equal "1.0", json_body["version"]
  end

  test "site api at path" do
    assert_raise(ActionController::RoutingError) { get "/foo/api/info" }
    site = Site.create(path: "foo")
    assert_nothing_raised { get "/foo/api/info" }
    assert_redirected_to "/session/new"
    SiteUser.create(site: site, user: @user)
    assert_nothing_raised { get "/foo/api/info" }
    assert_equal "1.0", json_body["version"]
  end

  test "sites api" do
    get "/api/sites", format: "json"
    assert_equal 0, json_body['sites'].size
    site = Site.create(path: "foo")
    get "/api/sites", format: "json"
    assert_equal 0, json_body['sites'].size
    SiteUser.create(site: site, user: @user)
    get "/api/sites", format: "json"
    assert_equal 1, json_body['sites'].size
    assert_equal "foo", json_body['sites'].first['path']
  end

end
