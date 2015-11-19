class Site < ActiveRecord::Base
  scope :path, proc { |p| where(path: p) }
  scope :domain, proc { |d| where("domain = :d OR domain IS NULL", d: d) }

  def to_param
    path
  end

  def schema
    Rails.env.production? ? "https" : "http"
  end

  def url
    "#{schema}://#{domain}/#{path}"
  end
end
