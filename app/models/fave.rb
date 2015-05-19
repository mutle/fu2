class Fave < ActiveRecord::Base
  include SiteScope
  
  belongs_to :user
  belongs_to :post
end
