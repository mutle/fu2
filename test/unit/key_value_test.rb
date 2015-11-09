require 'test_helper'

class KeyValueTest < ActiveSupport::TestCase
  test "set key value" do
    t = Time.now.to_f.to_s
    assert_nil KeyValue.get("test-#{t}")
    KeyValue.set("test-#{t}", "1")
    assert_equal "1", KeyValue.get("test-#{t}")
  end

  test "add to array value" do
    t = Time.now.to_f.to_s
    assert_equal [], KeyValue.get("test-#{t}[]")
    KeyValue.set("test-#{t}[]", "1")
    assert_equal ["1"], KeyValue.get("test-#{t}[]")
    KeyValue.set("test-#{t}[]", "2")
    assert_equal ["1", "2"], KeyValue.get("test-#{t}[]")
  end
end
