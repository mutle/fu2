require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "event stores data" do
    e = Event.create(event: "test", data: {'key' => "value"})
    assert_equal "value", e.data['key']
  end

end
