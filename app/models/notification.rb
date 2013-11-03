class Notification < ActiveRecord::Base
  attr_accessible :created_by_name, :created_by_id, :deleted, :message, :metadata, :notification_type, :read, :reference_notification_id, :user_id, :channel_id, :post_id

  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  belongs_to :channel
  belongs_to :post

  scope :for_user, proc { |user|
    where(:user_id => user.id).order("notifications.id DESC")
  }
  scope :since, proc { |id| where("id > ?", id) }
  scope :read, proc { where("read = ?", true) }
  scope :unread, proc { where("read = ?", false) }
  scope :messages, proc { where(:notification_type => "message") }
  scope :mentions, proc { where(:notification_type => "mention") }
  scope :toolbar_notifications, proc { where(:notification_type => ["message", "mention"]) }
  scope :from, proc { |user| messages.where(:created_by_id => user.id) }

  class << self
    def mention(from, to, channel, post)
      attrs = {
        :user_id => to.id,
        :created_by_id => from.id,
        :notification_type => "mention",
        :channel_id => channel.id,
        :post_id => post.id
      }
      create(attrs)
    end

    def message(from, to, message, no_response=false)
      attrs = {
        :user_id => to.id,
        :created_by_id => from.id,
        :notification_type => "message",
        :message => message
      }
      m = create(attrs)
      if !no_response && from.id != to.id
        attrs = {
          :user_id => from.id,
          :reference_notification_id => m.id,
          :created_by_id => to.id,
          :notification_type => "response",
          :message => message
        }
        create(attrs)
      end
      m.process_fubot_message
      m
    end
  end

  def message(rendered=true)
    m = super() || default_message
    rendered ? render_message(m) : m
  end

  def process_fubot_message
    Resque.enqueue(FubotJob, self.id) if user_id == 40 && notification_type == "message"
  end

  def process_fubot_message!
    if user_id == 40 && notification_type == "message"
      response = Fubot.new.call(self.message(false))
      if response
        self.class.message(user, created_by, response.text, true)
      end
    end
  end

  private

  def render_message(message)
    RenderPipeline.notification(message)
  end

  def default_message
    if notification_type == "mention"
      "I mentioned you in [#{channel.title}](/channels/#{channel_id}#post_#{post_id})"
    end
  end
end
