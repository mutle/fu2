CarrierWave.configure do |config|
  config.storage = Rails.env.production? ? :webdav : :file
end
