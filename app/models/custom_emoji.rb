class CustomEmoji < ActiveRecord::Base
  belongs_to :user
  class << self
    def all_emojis
      custom_emojis + default_emojis
    end

    def custom_emojis
      all.includes(:user).to_a.map(&:as_json) + user_emojis
    end

    def user_emojis
      User.active.to_a.map { |u| for_user(u) }
    end

    def default_emojis
      Emoji.all.map { |e| {aliases: e.aliases, tags: e.tags, unicode_aliases: e.unicode_aliases, image: "/images/emoji/"+e.image_filename} }
    end

    def for_user(user)
      {
        aliases: [user.login.downcase],
        tags: [],
        image: user.avatar_image_url
      }
    end

    def last_update
      e = order("updated_at DESC").first
      if e
        e.updated_at.to_i
      else
        0
      end
    end

    def all_emojis_cached
      last = $redis.get("CustomEmoji:All:Updated")
      if !last || last.to_i < last_update
        text = {emojis: CustomEmoji.all_emojis}.to_json
        $redis.set("CustomEmoji:All:json", text)
        $redis.set("CustomEmoji:All:Updated", last_update)
        text
      else
        $redis.get("CustomEmoji:All:json")
      end
    end
  end

  def as_json
    {
      aliases: [name.downcase],
      unicode_aliases: [],
      tags: [alias_list],
      image: url
    }
  end

  def alias_list
    (aliases || "").gsub(/\w/, '').split(",") + ["by #{user.login}"]
  end
end
