class KeyValue < ActiveRecord::Base
  include SiteScope

  class << self
    def get(site, key)
      if key =~ /\[\]$/
        site_scope(site).where(key: key).map(&:value)
      else
        site_scope(site).where(key: key).first.try(:value)
      end
    end

    def set(site, key, value)
      if key =~ /\[\]$/
        create(key: key, value: value, site_id: site.id)
      else
        create_with(value: value).find_or_create_by(key: key, site_id: site.id)
      end
    end
  end
end
