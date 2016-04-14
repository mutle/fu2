class SiteConstraint
  def matches?(request)
    path = request.params[:site_path] || ""
    site = Site.path(path).first
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
    def site_scope(site_id)
      where(site_id: site_id)
    end
  end

end
