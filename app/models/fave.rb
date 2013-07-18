class Fave < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  scope :most_popular, proc { select("id, user_id, post_id, (SELECT count(*) FROM \"faves\" AS f2 where f2.post_id = faves.post_id) AS post_count").order("post_count DESC").limit(300) }
end
