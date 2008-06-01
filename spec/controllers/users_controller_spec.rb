require File.dirname(__FILE__) + '/../spec_helper'
# 
# # Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# # Then, you can remove it from this and the units test.
# include AuthenticatedTestHelper
# 
# describe UsersController do
#   fixtures :users
#   
#   before(:each) do
#     create_user
#   end
# 
#   it 'allows signup' do
#     lambda do
#       do_post
#       response.should be_redirect      
#     end.should change(User, :count).by(1)
#   end
# 
#   
# 
#   
#   it 'signs up user with activation code' do
#     do_post
#     assigns(:user).activation_code.should_not be_nil
#   end
# 
#   it 'requires login on signup' do
#     lambda do
#       do_post(:login => nil)
#       assigns[:user].errors.on(:login).should_not be_nil
#       response.should be_success
#     end.should_not change(User, :count)
#   end
#   
#   it 'requires password on signup' do
#     lambda do
#       do_post(:password => nil)
#       assigns[:user].errors.on(:password).should_not be_nil
#       response.should be_success
#     end.should_not change(User, :count)
#   end
#   
#   it 'requires password confirmation on signup' do
#     lambda do
#       do_post(:password_confirmation => nil)
#       assigns[:user].errors.on(:password_confirmation).should_not be_nil
#       response.should be_success
#     end.should_not change(User, :count)
#   end
# 
#   it 'requires email on signup' do
#     lambda do
#       do_post(:email => nil)
#       assigns[:user].errors.on(:email).should_not be_nil
#       response.should be_success
#     end.should_not change(User, :count)
#   end
#   
#   
#   it 'activates user' do
#     User.authenticate('aaron', 'test').should be_nil
#     get :activate, {:activation_code => users(:aaron).activation_code}, {:user_id => @user.id}
#     response.should redirect_to('/')
#     flash[:notice].should_not be_nil
#     User.authenticate('aaron', 'test').should == users(:aaron)
#   end
#   
#   it 'does not activate user without key' do
#     get :activate, {}, {:user_id => @user.id}
#     flash[:notice].should be_nil
#   end
#   
#   it 'does not activate user with blank key' do
#     get :activate, {:activation_code => ''}, {:user_id => @user.id}
#     flash[:notice].should be_nil
#   end
#   
#   def do_post(options = {})
#     post :create, {:user => { :login => 'quire', :email => 'quire@example.com',
#       :password => 'quire', :password_confirmation => 'quire' }.merge(options)}, {:user_id => @user.id}
#   end
# end