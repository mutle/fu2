require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest

  setup do
    login_user
  end

  test "root site api" do
    assert_raise(ActionController::RoutingError) { get "/api/info" }
    Site.create(path: "")
    assert_nothing_raised { get "/api/info" }
    assert_equal "1.0", json_body["version"]
  end

  test "site api at path" do
    assert_raise(ActionController::RoutingError) { get "/foo/api/info" }
    Site.create(path: "foo")
    assert_nothing_raised { get "/foo/api/info" }
    assert_equal "1.0", json_body["version"]
  end

end
