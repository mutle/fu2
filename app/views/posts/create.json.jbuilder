json.post do
  json.partial! 'shared/post', post: @post
  json.rendered json.context.render_to_string(:partial => "channels/post", :object => @post, :format => :html)
end
