require File.dirname(__FILE__) + '/../spec_helper'

describe ChannelUser do
  before(:each) do
    @channel_user = ChannelUser.new
  end

  it "should be valid" do
    @channel_user.should be_valid
  end
end
