# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

u = User.create(:login => "admin", :password => "admin", :password_confirmation => "admin", :email => "admin@example.com")
u.activate

Site.create(name: "Main", path: "", user_id: 1)
Site.create(name: "Test-Path", path: "test", user_id: 1)

SiteUser.create(user_id: 1, site_id: 1)
SiteUser.create(user_id: 1, site_id: 2)


puts "You can now login as admin/admin."
