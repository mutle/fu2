require 'digest/sha1'

class Upload < ActiveRecord::Base
  
  belongs_to :user
  
  
  def file=(uploaded_file)
    self.file_name = uploaded_file.original_filename.gsub(/\.([^\.]*)$/, '')
    self.file_ext = File.extname(uploaded_file.original_filename).gsub(/^\./, '')
    self.file_id = Digest::SHA1.hexdigest("#{Time.now.to_i}_#{self.user_id}_#{self.file_name}")
    FileUtils.move uploaded_file.local_path, file_path
  end
  
  def download_path
    "uploads/#{file_id}.#{file_ext}"
  end
  
  def file_path
    "#{RAILS_ROOT}/public/#{download_path}"
  end
  
  def image?
    file_ext =~ /^png|gif|jpg|jpeg$/i
  end
  
end
