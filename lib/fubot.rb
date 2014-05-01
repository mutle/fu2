class Fubot

  TRIGGER_PATTERNS = [
    /\/?fubot /,
    /\//,
  ]

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
    message.each_line do |l|
      match_line l do |result|
        return result
      end
    end
    nil
  end

  def reply(message)
    Fubot::Message.new(message)
  end

end

Fubot.load_commands
