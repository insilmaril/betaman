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

ActiveRecord::Schema.define(:version => 20140328113324) do

  create_table "accounts", :force => true do |t|
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "addresses", :force => true do |t|
    t.string   "address1"
    t.string   "address2"
    t.string   "address3"
    t.string   "city"
    t.string   "zip"
    t.string   "country"
    t.string   "state"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "betas", :force => true do |t|
    t.string   "name"
    t.date     "begin"
    t.date     "end"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "alias"
    t.string   "novell_id"
    t.string   "novell_user"
    t.string   "novell_pass"
    t.string   "novell_iw_user"
    t.string   "novell_iw_pass"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "diary_entries", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.text     "text"
    t.string   "event"
    t.integer  "beta_id"
    t.integer  "actor_id"
    t.integer  "list_id"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.string   "pass"
    t.string   "server"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "beta_id"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "miles", :force => true do |t|
    t.integer  "milestone_id"
    t.integer  "beta_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "milestones", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.text     "comment"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "comment_internal"
    t.string   "url"
  end

  create_table "participations", :force => true do |t|
    t.string   "status"
    t.integer  "user_id"
    t.integer  "beta_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.text     "note"
    t.boolean  "downloads_act"
    t.boolean  "support_req"
    t.boolean  "support_act"
    t.boolean  "active",        :default => true
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "login_name"
    t.integer  "address_id"
    t.text     "note"
    t.integer  "company_id"
    t.string   "title"
    t.string   "alt_email"
  end

end
