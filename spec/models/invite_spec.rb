require File.dirname(__FILE__) + '/../spec_helper'


module InviteSpecHelper
  def valid_attributes(user)
    {:email => "test@example.com", :user_id => user.id}
  end
end

describe Invite do
  include InviteSpecHelper
  
  before(:each) do
    create_user
    @invite = Invite.new(valid_attributes(@user))
  end

  it "should be valid" do
    @invite.should be_valid
  end
  
  it "should generate an activation code" do
    @invite.save
    @invite.activation_code.should_not be_blank
  end
  
  it "should send an email to the user" do
    UserMailer.should_receive(:deliver_invite).with(@invite)
    @invite.save
  end
  
end
