class Event < ActiveRecord::Base
  scope :from_post, proc { |p| where("created_at >= :p", p: p.created_at).order("created_at") }
  belongs_to :channel
  belongs_to :user

  serialize :data, JSON

  attr_accessor :read

  MESSAGE = {
    "rename" => proc { |e| "title changed from *#{e.data['old_title']}* to *#{e.data['title']}*"},
    "merge" => proc { |e| "merged *#{e.data['merged_title']}* into *#{e.data['title']}*"}
  }

  def event_message
    MESSAGE[event].call(self) || ""
  end

end
