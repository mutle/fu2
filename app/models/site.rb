class Site < ActiveRecord::Base
  scope :path, proc { |p| where(path: p) }
end
