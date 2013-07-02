require 'net/dav'

module CarrierWave
  module Storage
    class Webdav < Abstract

      class File
        attr_reader :path
        def server_name
          ENV['WEBDAV_SERVER']
        end
        def server_url
          "http://#{server_name}/"
        end
        def connection
          @connection ||= Net::DAV.new(server_url)
        end
        def attributes
          file.attributes
        end
        def extension
          path.split('.').last
        end
        def initialize(uploader, base, path)
          @uploader, @base, @path = uploader, base, path
        end
        def store(new_file)
          connection.put(@uploader.store_path, new_file.to_file, new_file.size)
          true
        end
        def url(options = {})
          "http://files.fu2.redcursor.net/#{path}"
        end
      end


      def store!(file)
        f = CarrierWave::Storage::Webdav::File.new uploader, self, uploader.store_path
        f.store(file)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::Fog::File.new(uploader, self, uploader.store_path(identifier))
      end

    end
  end
end
