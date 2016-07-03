require 'open-uri'
require 'json'
require 'fubot/js_command'

class Fubot

  TRIGGER_PATTERNS = [
    /\/?fubot /,
    /\//,
  ]
  attr_accessor :user, :responder, :site

  class << self
    def commands
      @commands ||= {}
    end

    def command(pattern, &block)
      klass = Class.new(&block)
      commands[pattern] = klass
    end

    def load_commands
      Dir.glob File.join(File.dirname(__FILE__), "fubot", "commands", "fubot_*.rb") do |f|
        require f
      end
    end
  end

  class Message
    attr_accessor :text

    def initialize(text)
      @text = text
    end
  end

  def initialize(responder=nil, user=nil, site=nil)
    @responder = responder
    @user = user
    @site = site
  end

  def match_line(line)
    trigger = false
    TRIGGER_PATTERNS.each do |t|
      if m = t.match(line)
        line = m.post_match
        trigger = true
      end
    end
    return if !trigger
    self.class.commands.each do |pattern,command|
      pat = /\A#{pattern}/
      if results = pat.match(line)
        yield command.new.call(self, results, line)
      end
    end
    nil
  end

  def call(message)
    line = message.lines.last
    match_line line do |result|
      return result
    end
    nil
  end

  def reply(message)
    m = Fubot::Message.new(message)
    @responder.send_fubot_message m if @responder
    m
  end

end

Fubot.load_commands
