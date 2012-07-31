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

ActiveRecord::Schema.define(:version => 20120731023612) do

  create_table "online_records", :force => true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "online_records", ["key"], :name => "index_online_records_on_key"
  add_index "online_records", ["user_id"], :name => "index_online_records_on_user_id"

  create_table "user_weibo_auths", :force => true do |t|
    t.integer  "user_id"
    t.string   "auth_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.integer  "expires_in"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                      :default => "", :null => false
    t.string   "hashed_password",           :default => "", :null => false
    t.string   "salt",                      :default => "", :null => false
    t.string   "email",                     :default => "", :null => false
    t.string   "sign"
    t.string   "activation_code"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "activated_at"
    t.string   "reset_password_code"
    t.datetime "reset_password_code_until"
    t.datetime "last_login_time"
    t.boolean  "send_invite_email"
    t.integer  "reputation",                :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weibo_comments", :force => true do |t|
    t.integer  "weibo_comment_id", :limit => 8
    t.string   "text"
    t.integer  "weibo_user_id",    :limit => 8
    t.integer  "weibo_status_id",  :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weibo_statuses", :force => true do |t|
    t.integer  "weibo_status_id",     :limit => 8
    t.integer  "weibo_user_id",       :limit => 8
    t.string   "text"
    t.integer  "retweeted_status_id", :limit => 8
    t.string   "bmiddle_pic"
    t.string   "original_pic"
    t.string   "thumbnail_pic"
    t.text     "json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weibo_statuses", ["weibo_status_id"], :name => "index_weibo_statuses_on_weibo_status_id"
  add_index "weibo_statuses", ["weibo_user_id"], :name => "index_weibo_statuses_on_weibo_user_id"

  create_table "weibo_users", :force => true do |t|
    t.integer  "weibo_user_id",     :limit => 8
    t.string   "screen_name"
    t.string   "profile_image_url"
    t.string   "gender"
    t.text     "description"
    t.text     "json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weibo_users", ["weibo_user_id"], :name => "index_weibo_users_on_weibo_user_id"

end
