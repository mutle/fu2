require 'test_helper'

class ViewModelTest < ActiveSupport::TestCase

  def setup
    create_user
    create_channel
    create_post
  end

  class TestViewModel < ViewModel
    attrs :test_id

    fetches :test_data_2, proc { test_data.posts.all }, [:test_data]
    fetches :test_data, proc { Channel.find(test_id) }
  end

  test "fetches data" do
    m = TestViewModel.new(test_id: @channel.id)
    assert_nil m.test_data
    m.finalize
    assert_not_nil m.test_data
    assert_equal @channel.id, m.test_data.id
  end

  test "fetches dependent data" do
    m = TestViewModel.new(test_id: @channel.id)
    assert_nil m.test_data_2
    m.finalize
    assert_not_nil m.test_data_2
  end

end
