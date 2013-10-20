class FubotJob < Resque::Job
  @queue = :fubot_queue

  def self.perform(notification_id)
    new(notification_id).perform
  end

  def initialize(notification_id)
    @notification_id = notification_id
  end

  def perform
    @notification = Notification.find(@notification_id)
    @notification.process_fubot_message!
  end
end
