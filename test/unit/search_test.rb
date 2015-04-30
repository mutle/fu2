require 'test_helper'

class SearchTest < ActiveSupport::TestCase

  setup do
    Search.reset_index
  end

  def update_index
    Search.update_index
    sleep 1
  end

  test "update index" do
    u = create_user
    p = create_post
    update_index
    assert_equal 4, $elastomer.get('/_search').body["hits"]["total"]
  end

  test "query" do
    q = Search.query("a:b foo \"bar baz\"").query
    p q
    assert_equal 3, q.size
  end

end
