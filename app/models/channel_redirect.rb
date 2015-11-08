class ChannelRedirect < ActiveRecord::Base
  scope :from_id, proc { |id| where(original_channel_id: id).first }
end
