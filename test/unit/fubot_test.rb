require 'test_helper'

require 'fubot'

class FubotTest < ActiveSupport::TestCase

  setup do
    @bot = Fubot.new
  end

  test "load commands" do
    assert Fubot.commands.size > 0
  end

  test "ignore messages without a command" do
    assert_nil @bot.call("hello!")
  end

  test "execute command" do
    assert_not_nil @bot.call("/help")
  end

end
