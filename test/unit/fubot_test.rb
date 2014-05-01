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

  test "command requires trigger pattern" do
    assert_nil @bot.call("help")
    assert_nil @bot.call("/foo help")
    assert_not_nil @bot.call("/help")
    assert_not_nil @bot.call("fubot help")
  end

end
