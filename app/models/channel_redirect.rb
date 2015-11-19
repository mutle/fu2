class ChannelRedirect < ActiveRecord::Base
  include SiteScope
  
  scope :from_id, proc { |id| where(original_channel_id: id).first }
end
