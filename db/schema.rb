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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151031235058) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channel_redirects", force: :cascade do |t|
    t.integer  "original_channel_id"
    t.integer  "target_channel_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "channel_redirects", ["original_channel_id"], name: "index_channel_redirects_on_original_channel_id", using: :btree
  add_index "channel_redirects", ["target_channel_id"], name: "index_channel_redirects_on_target_channel_id", using: :btree

  create_table "channels", force: :cascade do |t|
    t.string   "title",          limit: 255,                null: false
    t.integer  "user_id",                                   null: false
    t.string   "permalink",      limit: 255,                null: false
    t.boolean  "default_read",               default: true, null: false
    t.boolean  "default_write",              default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_post_date"
    t.text     "text"
    t.integer  "updated_by"
    t.integer  "site_id",                    default: 1
  end

  add_index "channels", ["created_at"], name: "index_channels_on_created_at", using: :btree
  add_index "channels", ["permalink"], name: "index_channels_on_permalink", using: :btree
  add_index "channels", ["site_id"], name: "index_channels_on_site_id", using: :btree
  add_index "channels", ["title"], name: "index_channels_on_title", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "channel_id"
    t.integer  "user_id"
    t.string   "event"
    t.text     "data"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "events", ["channel_id"], name: "index_events_on_channel_id", using: :btree
  add_index "events", ["event"], name: "index_events_on_event", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "faves", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.integer  "post_id",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "site_id",    default: 1
    t.string   "emoji",      default: "star"
  end

  add_index "faves", ["emoji"], name: "index_faves_on_emoji", using: :btree
  add_index "faves", ["post_id"], name: "index_faves_on_post_id", using: :btree
  add_index "faves", ["site_id"], name: "index_faves_on_site_id", using: :btree
  add_index "faves", ["user_id"], name: "index_faves_on_user_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.string   "image_file", limit: 255
    t.string   "filename",   limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "site_id",                default: 1
  end

  add_index "images", ["site_id"], name: "index_images_on_site_id", using: :btree

  create_table "invite_approvals", force: :cascade do |t|
    t.integer  "invite_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "activation_code", limit: 255
    t.boolean  "approved",                    default: false, null: false
    t.boolean  "sent",                        default: false, null: false
    t.text     "approved_users"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "reference_notification_id"
    t.string   "notification_type",         limit: 255
    t.string   "created_by_name",           limit: 255
    t.integer  "created_by_id"
    t.integer  "channel_id"
    t.integer  "post_id"
    t.text     "message"
    t.text     "metadata"
    t.boolean  "read",                                  default: false
    t.boolean  "deleted",                               default: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "site_id",                               default: 1
  end

  add_index "notifications", ["channel_id"], name: "index_notifications_on_channel_id", using: :btree
  add_index "notifications", ["created_by_id"], name: "index_notifications_on_created_by_id", using: :btree
  add_index "notifications", ["deleted"], name: "index_notifications_on_deleted", using: :btree
  add_index "notifications", ["notification_type"], name: "index_notifications_on_notification_type", using: :btree
  add_index "notifications", ["post_id"], name: "index_notifications_on_post_id", using: :btree
  add_index "notifications", ["read"], name: "index_notifications_on_read", using: :btree
  add_index "notifications", ["reference_notification_id"], name: "index_notifications_on_reference_notification_id", using: :btree
  add_index "notifications", ["site_id"], name: "index_notifications_on_site_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "channel_id",                 null: false
    t.integer  "user_id",                    null: false
    t.text     "body",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "markdown",   default: false
    t.integer  "site_id",    default: 1
  end

  add_index "posts", ["channel_id"], name: "index_posts_on_channel_id", using: :btree
  add_index "posts", ["created_at"], name: "index_posts_on_created_at", using: :btree
  add_index "posts", ["site_id"], name: "index_posts_on_site_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "sites", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "domain",     limit: 255
    t.string   "path",       limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["domain"], name: "index_sites_on_domain", using: :btree
  add_index "sites", ["path"], name: "index_sites_on_path", using: :btree
  add_index "sites", ["user_id"], name: "index_sites_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.integer  "invite_user_id",                        default: 0
    t.string   "display_name",              limit: 255
    t.integer  "account_type",                          default: 0
    t.string   "color",                     limit: 255
    t.integer  "stylesheet_id",                         default: 0,    null: false
    t.integer  "number_unread_messages",                default: 0
    t.text     "block_users"
    t.string   "password_hash",             limit: 255
    t.string   "api_key",                   limit: 255, default: ""
    t.boolean  "markdown",                              default: true
    t.text     "avatar_url"
    t.integer  "site_id",                               default: 1
  end

  add_index "users", ["activation_code"], name: "index_users_on_activation_code", using: :btree
  add_index "users", ["crypted_password"], name: "index_users_on_crypted_password", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", using: :btree
  add_index "users", ["site_id"], name: "index_users_on_site_id", using: :btree

end
