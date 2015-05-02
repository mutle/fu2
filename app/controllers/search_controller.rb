class SearchController < ApplicationController

  before_filter :login_required

  respond_to :html, :json

  def show
    @query = params[:search].to_s
    page = (params[:page] || 1).to_i
    @view = Views::Search.new({
      query: @query,
      page: page
    })
    @view.finalize
    @action = 'search'

    respond_to do |format|
      format.html
      format.json { render :json => @view.results }
    end
  end
end
