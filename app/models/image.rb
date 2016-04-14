class Image < ActiveRecord::Base
  include SiteScope
  
  mount_uploader :image_file, ImageUploader
  belongs_to :user

  def as_json(*args)
    {:created_at => created_at, :id => id, :filename => filename, :url => image_file.url, :user_id => user_id, :post_id => post_id}
  end
end
