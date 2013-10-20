require 'test_helper'

class ChannelsTest < ActionController::IntegrationTest

  def setup
    @u = create_user "testuser", "testpw"
  end

  test "list channels" do
    login "testuser", "testpw"
    c = Channel.create(:user_id => @u.id, :title => "Foo Channel")
    get '/'
    assert_select "li a", :text => "Foo Channel"
  end

end
