class StylesheetsController < ApplicationController
  
  def index
    @stylesheets = Stylesheet.all(:order => "LOWER(title)")
  end
  
  def show
    @stylesheet = Stylesheet.find(params[:id].to_i)
    
    respond_to do |format|
      format.css { render :text => @stylesheet.code }
    end
  end
  
  def new
    
  end
  
  def create
    @stylesheet = Stylesheet.create(params[:stylesheet].merge(:user_id => current_user.id))
    
    redirect_to stylesheets_path
  end
  
  def edit
    @stylesheet = Stylesheet.find(params[:id].to_i)
    
    raise ActiveRecord::RecordNotFound unless @stylesheet.user_id == current_user.id
  end
  
  def update
    @stylesheet = Stylesheet.find(params[:id].to_i)
    
    @stylesheet.update_attributes(params[:stylesheet]) if @stylesheet.user_id == current_user.id
    
    redirect_to stylesheets_path
  end
  
end
