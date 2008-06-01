require File.dirname(__FILE__) + '/../spec_helper'

describe ChannelsController do

  #Delete this example and add some real ones
  it "should use ChannelsController" do
    controller.should be_an_instance_of(ChannelsController)
  end

end



describe ChannelsController, "#index" do
  
  before(:each) do
    mocked_user
  end
  
  def do_get
    get :index, {}, {:user_id => 1}
  end
  
  it "should get a list of recent acitivities" do
    Channel.should_receive(:recent_channels).and_return([])
    do_get
  end
  
end

describe ChannelsController, "#create" do
  
  before(:each) do
    mocked_user
  end
  
  def do_post
    post :create, {:channel => {:title => "Test Channel"}}, {:user_id => 1}
  end
  
  it "should create the new channel" do
    Channel.should_receive(:create).and_return(mock_model(Channel))
    do_post
  end
  
end