module UploadsHelper
  
  def download_url(upload)
    "http://#{request.host_with_port}/#{upload.download_path}"
  end
  
  def image_code(upload)
    "<a href='#{upload_url(upload)}'><img src='#{download_url(upload)}' /></a>"
  end
  
end
