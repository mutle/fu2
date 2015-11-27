require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  test "SiteConstraint matches path" do
    s = SiteConstraint.new
    env = stub(params: {site_path: "foo"}, env: {})
    assert !s.matches?(env)
    Site.create(path: "foo")
    assert s.matches?(env)
  end

  [Channel, ChannelRedirect, Event, Fave, Image, Invite, KeyValue, Notification, Post].each do |klass|
    test "#{klass} site scope" do
      assert_nothing_raised { klass.site_scope(1) }
    end
  end

end
