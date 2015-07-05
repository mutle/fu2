$elastomer = Elastomer::Client.new url: ENV["ELASTICSEARCH_URL"] || "http://localhost:9200"
