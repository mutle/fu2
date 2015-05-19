require 'test_helper'

class PostTest < ActiveSupport::TestCase

  test "fave post" do
    u = create_user
    p = create_post
    assert !p.faved_by?(u)
    p.fave(u)
    assert p.faved_by?(u)
    p.unfave(u)
    assert !p.faved_by?(u)
  end

end
