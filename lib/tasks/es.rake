task "es:reindex" => :environment do
  Search.reset_index
  Search.update_index
end
