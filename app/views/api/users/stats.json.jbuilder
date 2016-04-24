json.type "user-#{@view.user.id}-stats"
json.(@view, :last_active, :posts_count, :channels_count, :faves_count, :faves_received, :emojis, :title)

json.last_posts @view.last_posts do |post|
  json.partial! 'shared/post', post: post
end

json.last_faves @view.last_faves do |fave|
  json.partial! 'shared/post', post: fave.post
end
