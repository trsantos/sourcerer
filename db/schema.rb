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

ActiveRecord::Schema.define(version: 20151019150958) do

  create_table "entries", force: :cascade do |t|
    t.text     "title"
    t.text     "description"
    t.datetime "pub_date"
    t.text     "url"
    t.integer  "feed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "image"
  end

  add_index "entries", ["feed_id"], name: "index_entries_on_feed_id"
  add_index "entries", ["title"], name: "index_entries_on_title"

  create_table "feeds", force: :cascade do |t|
    t.text     "title"
    t.text     "feed_url"
    t.text     "site_url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "logo"
    t.text     "description"
  end

  add_index "feeds", ["feed_url"], name: "index_feeds_on_feed_url", unique: true

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "feed_id"
    t.text     "title"
    t.text     "site_url"
    t.datetime "visited_at"
    t.boolean  "starred",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "from_topic", default: false
    t.boolean  "updated",    default: true
  end

  add_index "subscriptions", ["feed_id"], name: "index_subscriptions_on_feed_id"
  add_index "subscriptions", ["updated"], name: "index_subscriptions_on_updated"
  add_index "subscriptions", ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id"

  create_table "topic_subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "topic_subscriptions", ["topic_id"], name: "index_topic_subscriptions_on_topic_id"
  add_index "topic_subscriptions", ["user_id", "topic_id"], name: "index_topic_subscriptions_on_user_id_and_topic_id", unique: true
  add_index "topic_subscriptions", ["user_id"], name: "index_topic_subscriptions_on_user_id"

  create_table "topics", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",                    default: false
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "paypal_payment_id"
    t.datetime "expiration_date"
    t.datetime "subscriptions_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
