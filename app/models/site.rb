class Site < ActiveRecord::Base
  scope :path, proc { |p| where(path: p) }
  scope :domain, proc { |d| where("domain = :d OR domain IS NULL", d: d) }
  has_many :site_users
  has_many :users, through: :site_users

  def to_param
    path
  end

  def schema
    Rails.env.production? ? "https" : "http"
  end

  def url
    "#{schema}://#{domain}/#{path}"
  end

  def user?(user)
    !SiteUser.site_scope(self).where(user_id: user).first.nil?
  end
end
