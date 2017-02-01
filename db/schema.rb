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

ActiveRecord::Schema.define(version: 20160803114153) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_requests", force: :cascade do |t|
    t.string   "url"
    t.string   "scheme"
    t.string   "host"
    t.string   "path"
    t.string   "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meetup_events", force: :cascade do |t|
    t.string   "meetup_dot_com_id"
    t.string   "name"
    t.decimal  "time"
    t.string   "utc_offset"
    t.string   "link"
    t.integer  "user_id"
    t.string   "venue_name"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["user_id"], name: "index_meetup_events_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.text     "data"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "venues", force: :cascade do |t|
    t.integer  "meetup_event_id"
    t.integer  "venue_id"
    t.string   "name"
    t.decimal  "latitude",        precision: 21, scale: 16
    t.decimal  "longitude",       precision: 21, scale: 16
    t.boolean  "repinned"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.integer  "zip"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["meetup_event_id"], name: "index_venues_on_meetup_event_id", using: :btree
  end

  add_foreign_key "meetup_events", "users"
  add_foreign_key "venues", "meetup_events"
end
