require 'test_helper'

class SearchTest < ActiveSupport::TestCase

  setup do
    Search.reset_index
  end

  def update_index
    Search.update_index
    wait_for_es
  end

  def wait_for_es
    sleep 1
  end

  test "update index" do
    u = create_user
    p = create_post
    Search.reset_index
    update_index
    assert_equal 1, $elastomer.get('/channels-test/_search').body["hits"]["total"]
  end

  # test "query" do
  #   q = Search.query("a:b foo \"bar baz\"").query
  #   p q
  #   assert_equal 3, q.size
  # end

  test "indexes after create" do
    Search.setup_index
    u = create_user
    p = create_post
    wait_for_es
    assert_equal 1, $elastomer.get('/channels-test/_search').body["hits"]["total"]
  end

end
