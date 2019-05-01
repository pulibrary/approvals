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

ActiveRecord::Schema.define(version: 2019_05_01_172949) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.bigint "head_id"
    t.bigint "admin_assistant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_requests", force: :cascade do |t|
    t.bigint "recurring_event_id"
    t.date "start_date"
    t.date "end_date"
    t.string "location"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "request_id"
    t.index ["recurring_event_id"], name: "index_event_requests_on_recurring_event_id"
    t.index ["request_id"], name: "index_event_requests_on_request_id"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "request_id"
    t.bigint "creator_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_notes_on_request_id"
  end

  create_table "recurring_events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "creator_id"
    t.date "start_date"
    t.date "end_date"
    t.string "request_type"
    t.string "purpose"
    t.string "participation"
    t.string "travel_category"
    t.string "absence_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "cas", null: false
    t.string "uid", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "event_requests", "recurring_events"
  add_foreign_key "notes", "requests"
end
