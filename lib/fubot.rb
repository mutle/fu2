class Fubot

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
        p f
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

  def call(message)
    self.class.commands.each do |pattern,command|
      if results = pattern.match(message)
        return command.new.call(self, results, message)
      end
    end
    nil
  end

  def reply(message)
    Fubot::Message.new(message)
  end

end

Fubot.load_commands
