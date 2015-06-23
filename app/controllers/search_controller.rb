class SearchController < ApplicationController

  before_filter :login_required

  respond_to :html, :json

  def show
    @query = params[:search].to_s
    start = (params[:start] || 0).to_i
    @sort = params[:sort] || "score"
    @view = Views::Search.new({
      query: @query,
      start: start,
      sort: @sort
    })
    @view.finalize
    @action = 'search'

    respond_to do |format|
      format.html do
        if params[:update]
          render partial: "results", layout: false, locals: {include_counts: true}
        else
          render
        end
      end
      format.json { render :json => @view.results }
    end
  end
end
