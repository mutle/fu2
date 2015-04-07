module PostsHelper

  def rendered_post(post)
    render(:partial => "channels/post", :object => post, :format => :html)
  end

end
