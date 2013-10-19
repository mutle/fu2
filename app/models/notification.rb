class Notification < ActiveRecord::Base
  attr_accessible :created_by_name, :created_by_id, :deleted, :message, :metadata, :notification_type, :read, :reference_notification_id, :user_id, :channel_id, :post_id

  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  belongs_to :channel
  belongs_to :post

  scope :for_user, proc { |user|
    where(:user_id => user.id).order("notifications.created_at DESC")
  }
  scope :since, proc { |id| where("id > ?", id) }

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

    def message(from, to, message)
      attrs = {
        :user_id => to.id,
        :created_by_id => from.id,
        :notification_type => "message",
        :message => message
      }
      m = create(attrs)
      if from.id != to.id
        attrs = {
          :user_id => from.id,
          :created_by_id => to.id,
          :notification_type => "response",
          :message => message
        }
        return create(attrs)
      end
      m
    end
  end

  def message
    render_message(super || default_message)
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
