class FubotJob < Resque::Job
  @queue = :fubot_queue

  def self.perform(type, id)
    new(type, id).perform
  end

  def initialize(type, id)
    @type = type.to_sym
    @id = id
  end

  def perform
    Rails.logger.info [@type, @id]
    if @type == :notification
      @notification = Notification.find(@id)
      @notification.process_fubot_message!
    elsif @type == :post
      @post = Post.find(@id)
      @post.process_fubot_message!
    end
  end
end
