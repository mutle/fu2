require 'test_helper'

class ChannelsTest < ActionController::IntegrationTest

  def setup
    @u = create_user "testuser", "testpw"
  end

  test "list channels" do
    login "testuser", "testpw"
    c = Channel.create(:user_id => @u.id, :title => "Foo Channel")
    visit '/'
    # puts body
    assert has_css?("li a", :content => "Foo Channel")
  end

end
