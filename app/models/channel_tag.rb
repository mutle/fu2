class ChannelTag < ActiveRecord::Base
  include SiteScope

  belongs_to :channel
  belongs_to :post
  belongs_to :user

  class << self
    def all_tags(site)
      res = connection.query(<<-SQL)
SELECT DISTINCT(tag) FROM channel_tags WHERE site_id = #{site.id};
SQL
      res.map(&:first)
    end

    def channel_ids(site, tag)
      res = connection.query(<<-SQL)
SELECT DISTINCT(channel_id) FROM channel_tags WHERE site_id = #{site.id} AND tag = \'#{connection.quote_string(tag)}\';
SQL
      res.map(&:first).map(&:to_i)
    end

    def posts(site, tag)
      Post.where(site_id: site.id, channel_id: channel_ids(site,tag))
    end
  end

end
