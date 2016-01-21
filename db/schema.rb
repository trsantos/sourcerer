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

ActiveRecord::Schema.define(version: 20160121182535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "pub_date"
    t.string   "url"
    t.integer  "feed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "image"
  end

  add_index "entries", ["feed_id"], name: "index_entries_on_feed_id", using: :btree
  add_index "entries", ["title"], name: "index_entries_on_title", using: :btree

  create_table "feeds", force: :cascade do |t|
    t.string   "title"
    t.string   "feed_url"
    t.string   "site_url"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "logo"
    t.text     "description"
    t.integer  "topic_id"
    t.boolean  "has_only_images"
    t.boolean  "fetching",        default: true
  end

  add_index "feeds", ["feed_url"], name: "index_feeds_on_feed_url", unique: true, using: :btree
  add_index "feeds", ["topic_id"], name: "index_feeds_on_topic_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "feed_id"
    t.string   "title"
    t.string   "site_url"
    t.datetime "visited_at"
    t.boolean  "starred",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "updated",    default: true
    t.integer  "topic_id"
  end

  add_index "subscriptions", ["feed_id"], name: "index_subscriptions_on_feed_id", using: :btree
  add_index "subscriptions", ["topic_id"], name: "index_subscriptions_on_topic_id", using: :btree
  add_index "subscriptions", ["updated"], name: "index_subscriptions_on_updated", using: :btree
  add_index "subscriptions", ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true, using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topics_users", id: false, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "user_id"
  end

  add_index "topics_users", ["topic_id"], name: "index_topics_users_on_topic_id", using: :btree
  add_index "topics_users", ["user_id"], name: "index_topics_users_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "paypal_payment_id"
    t.datetime "expiration_date"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
