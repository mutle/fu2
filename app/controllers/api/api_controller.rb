class Api::ApiController < ApplicationController
  before_filter :login_required
  respond_to :json
end
