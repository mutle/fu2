module UploadsHelper
  
  def download_url(upload)
    "http://#{request.host_with_port}/#{upload.download_path}"
  end
  
  def image_code(upload)
    "<img src='#{download_url(upload)}' />"
  end
  
end
