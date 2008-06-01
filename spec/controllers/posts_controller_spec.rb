require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do

  #Delete this example and add some real ones
  it "should use PostsController" do
    controller.should be_an_instance_of(PostsController)
  end

end

describe PostsController, "#create" do
  
  before(:each) do
    @posts = mock("Posts")
    @channel = mock_model(Channel, :posts => @posts)
    @post = mock_model(Post)
    Channel.stub!(:find).with(1).and_return(@channel)
  end
  
  def do_post
    post :create, {:channel_id => 1, :post => {:body => "test"}}, {:user_id => 1}
  end
  
  it "should add the comment to the channel" do
    @posts.should_receive(:create).with(:body => "test", :user_id => 1).and_return(@post)
    do_post
  end
  
end