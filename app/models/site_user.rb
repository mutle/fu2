class SiteUser < ActiveRecord::Base
  belongs_to :site
  belongs_to :user

  scope :site_scope, proc { |site| where(site_id: site.id) }

  class << self
    def users(site)
      site_scope(site).includes(:user).all.map(&:user)
    end
  end
end
