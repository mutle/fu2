# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131019141111) do

  create_table "channel_users", :force => true do |t|
    t.integer  "channel_id",                   :null => false
    t.integer  "user_id",                      :null => false
    t.boolean  "priv_read",  :default => true, :null => false
    t.boolean  "priv_write", :default => true, :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "channel_visits", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "channel_visits", ["channel_id"], :name => "index_channel_visits_on_channel_id"
  add_index "channel_visits", ["user_id"], :name => "index_channel_visits_on_user_id"

  create_table "channels", :force => true do |t|
    t.string   "title",                           :null => false
    t.integer  "user_id",                         :null => false
    t.string   "permalink",                       :null => false
    t.boolean  "default_read",  :default => true, :null => false
    t.boolean  "default_write", :default => true, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.datetime "last_post"
    t.text     "text"
    t.integer  "updated_by"
  end

  add_index "channels", ["created_at"], :name => "index_channels_on_created_at"
  add_index "channels", ["permalink"], :name => "index_channels_on_permalink"
  add_index "channels", ["title"], :name => "index_channels_on_title"

  create_table "faves", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "post_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.string   "image_file"
    t.string   "filename"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "invites", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.string   "activation_code"
    t.boolean  "approved",        :default => false, :null => false
    t.boolean  "sent",            :default => false, :null => false
    t.text     "approved_users"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sender_id"
    t.integer  "status",     :default => 0
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "reference_notification_id"
    t.string   "notification_type"
    t.string   "created_by_name"
    t.integer  "created_by_id"
    t.integer  "channel_id"
    t.integer  "post_id"
    t.text     "message"
    t.text     "metadata"
    t.boolean  "read",                      :default => false
    t.boolean  "deleted",                   :default => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "notifications", ["channel_id"], :name => "index_notifications_on_channel_id"
  add_index "notifications", ["created_by_id"], :name => "index_notifications_on_created_by_id"
  add_index "notifications", ["deleted"], :name => "index_notifications_on_deleted"
  add_index "notifications", ["notification_type"], :name => "index_notifications_on_notification_type"
  add_index "notifications", ["post_id"], :name => "index_notifications_on_post_id"
  add_index "notifications", ["read"], :name => "index_notifications_on_read"
  add_index "notifications", ["reference_notification_id"], :name => "index_notifications_on_reference_notification_id"
  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "posts", :force => true do |t|
    t.integer  "channel_id",                    :null => false
    t.integer  "user_id",                       :null => false
    t.text     "body",                          :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "markdown",   :default => false
  end

  add_index "posts", ["channel_id"], :name => "index_posts_on_channel_id"
  add_index "posts", ["created_at"], :name => "index_posts_on_created_at"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "stylesheets", :force => true do |t|
    t.integer  "user_id"
    t.text     "title"
    t.text     "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "stylesheets", ["user_id"], :name => "index_stylesheets_on_user_id"

  create_table "uploads", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.string   "file_id",    :default => "", :null => false
    t.string   "file_name",  :default => "", :null => false
    t.string   "file_ext",   :default => "", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

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
    t.integer  "stylesheet_id",                           :default => 0,    :null => false
    t.integer  "number_unread_messages",                  :default => 0
    t.text     "block_users"
    t.string   "password_hash"
    t.string   "api_key",                                 :default => ""
    t.boolean  "markdown",                                :default => true
    t.text     "avatar_url"
  end

  add_index "users", ["activation_code"], :name => "index_users_on_activation_code"
  add_index "users", ["crypted_password"], :name => "index_users_on_crypted_password"
  add_index "users", ["login"], :name => "index_users_on_login"

end
