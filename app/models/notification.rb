class Notification < ActiveRecord::Base
  attr_accessible :created_by, :created_by_id, :deleted, :message, :metadata, :notification_type, :read, :reference_notification_id, :user_id
end
