require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  before(:each) do
    @post = Post.new
  end

  it "should be valid" do
    @post.should be_valid
  end
  
  it "should update the channel" do
    @channel = Channel.create(:title => "bla", :user_id => 1, :body => "first post")
    sleep 2
    p = @channel.posts.create(:user_id => 1, :body => "second post")
    @channel.reload
    @channel.last_post.should eql(@channel.posts.last.created_at)
  end
end
