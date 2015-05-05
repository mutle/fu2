class Fave < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end
