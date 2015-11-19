class Fave < ActiveRecord::Base
  include SiteScope
  
  belongs_to :user
  belongs_to :post

  class << self

    def user_emojis(user)
      emojis = {}
      Fave.where(user_id: user.id).all.each do |f|
        emojis[f.emoji] ||= 0
        emojis[f.emoji] += 1
      end
      emojis
    end

  end

end
