require File.dirname(__FILE__) + '/../spec_helper'


module ChannelSpecHelper
  def valid_attributes(user)
    {:title => "Test Channel", :body => "Hi", :user_id => user.id}
  end
end

describe Channel do
  
  include ChannelSpecHelper
  
  before(:each) do
    create_user
  end

  it "should be valid" do
    @channel = Channel.new(valid_attributes(@user))
    @channel.should be_valid
    @channel.save.should be_true
  end
  
  it "should generate a perma link" do
    @channel = Channel.create(valid_attributes(@user))
    @channel.permalink.should eql("Test_Channel")
  end
  
  it "should create a first post" do
    @channel = Channel.new(valid_attributes(@user))
    @channel.save
    @channel.posts.count.should eql(1)
    @channel.posts.first.body.should eql("Hi")
  end
end