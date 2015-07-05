json.post do
  json.partial! 'shared/post', post: @post
end
