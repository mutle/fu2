# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 11) do

  create_table "channel_users", :force => true do |t|
    t.integer  "channel_id",                   :null => false
    t.integer  "user_id",                      :null => false
    t.boolean  "priv_read",  :default => true, :null => false
    t.boolean  "priv_write", :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channel_visits", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "channel_visits", ["channel_id"], :name => "index_channel_visits_on_channel_id"
  add_index "channel_visits", ["user_id"], :name => "index_channel_visits_on_user_id"

  create_table "channels", :force => true do |t|
    t.string   "title",                           :null => false
    t.integer  "user_id",                         :null => false
    t.string   "permalink",                       :null => false
    t.boolean  "default_read",  :default => true, :null => false
    t.boolean  "default_write", :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_post"
  end

  add_index "channels", ["created_at"], :name => "index_channels_on_created_at"
  add_index "channels", ["permalink"], :name => "index_channels_on_permalink"
  add_index "channels", ["title"], :name => "index_channels_on_title"

  create_table "invites", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.string   "activation_code"
    t.boolean  "approved",        :default => false, :null => false
    t.boolean  "sent",            :default => false, :null => false
    t.text     "approved_users"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "channel_id",                 :null => false
    t.integer  "user_id",                    :null => false
    t.text     "body",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["channel_id"], :name => "index_posts_on_channel_id"
  add_index "posts", ["created_at"], :name => "index_posts_on_created_at"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "stylesheets", :force => true do |t|
    t.integer  "user_id"
    t.text     "title"
    t.text     "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stylesheets", ["user_id"], :name => "index_stylesheets_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "invite_user_id",                          :default => 0
    t.string   "display_name"
    t.integer  "account_type",                            :default => 0
    t.string   "color",                                   :default => ""
    t.integer  "stylesheet_id",                           :default => 0,  :null => false
  end

  add_index "users", ["activation_code"], :name => "index_users_on_activation_code"
  add_index "users", ["crypted_password"], :name => "index_users_on_crypted_password"
  add_index "users", ["login"], :name => "index_users_on_login"

end
