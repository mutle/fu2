require 'test_helper'

class KeyValueTest < ActiveSupport::TestCase
  test "set key value" do
    t = Time.now.to_f.to_s
    assert_nil KeyValue.get(@site, "test-#{t}")
    KeyValue.set(@site, "test-#{t}", "1")
    assert_equal "1", KeyValue.get(@site, "test-#{t}")
  end

  test "add to array value" do
    t = Time.now.to_f.to_s
    assert_equal [], KeyValue.get(@site, "test-#{t}[]")
    KeyValue.set(@site, "test-#{t}[]", "1")
    assert_equal ["1"], KeyValue.get(@site, "test-#{t}[]")
    KeyValue.set(@site, "test-#{t}[]", "2")
    assert_equal ["1", "2"], KeyValue.get(@site, "test-#{t}[]")
  end
end
