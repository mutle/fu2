puts "show"

json.post do
  json.partial! 'shared/post', post: @post
  json.rendered @rendered
end
