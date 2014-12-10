class SiteConstraint
  def initialize
  end

  def matches?(request)
    path = request.params[:site_path] || ""
    domain = request.host || ""
    p domain
    site = Site.path(path).domain(domain).first
    if site
      request.env['_site'] = site
      return true
    end
    false
  end
end

module SiteScope
  extend ActiveSupport::Concern

  module ClassMethods
    def site_scope_proc
      proc { where(site_id: site_id) }
    end

    def site_scope
      where(site_id: site_id)
    end

    def site_id
      Thread.current[:site_id]
    end

    def default_scope
      site_scope
    end
  end

end
