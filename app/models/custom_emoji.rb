class CustomEmoji < ActiveRecord::Base
  class << self
    def all_emojis
      custom_emojis + default_emojis
    end

    def custom_emojis
      all.to_a.map(&:as_json) + user_emojis
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
    (aliases || "").gsub(/\w/, '').split(",")
  end
end
