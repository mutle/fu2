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

  test "only evaluate last line on multi-line input" do
    assert_nil @bot.call("/help\nfoo")
    assert_not_nil @bot.call("foo\n/help")
  end

  test "command requires trigger pattern" do
    assert_nil @bot.call("help")
    assert_nil @bot.call("/foo help")
    assert_not_nil @bot.call("/help")
    assert_not_nil @bot.call("fubot help")
  end

  test "responder" do
    r = "1"
    @bot = Fubot.new(r)
    r.expects(:send_fubot_message)
    @bot.call("/help")
  end

  test "js command" do
    Fubot::JSCommand.new.call(@bot, [1,2], "foo")
  end

end
