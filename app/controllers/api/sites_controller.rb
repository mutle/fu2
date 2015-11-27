class Api::SitesController < Api::ApiController
  respond_to :json
  
  def index
    @sites = current_user.sites
  end
end
