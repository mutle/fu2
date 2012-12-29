require 'carrierwave/storage/webdav'
CarrierWave.configure do |config|
  config.storage = Rails.env.production? ? CarrierWave::Storage::Webdav : :file
end
