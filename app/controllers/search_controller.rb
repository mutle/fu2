class SearchController < ApplicationController

  before_filter :login_required

  def index
    empty_response
  end

  def show
    empty_response
  end
end
