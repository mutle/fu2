require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "update activity" do
    u = create_user
    assert_equal 0, u.last_active
    u.record_active
    assert_not_equal 0, u.last_active
  end

end
