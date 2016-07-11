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

ActiveRecord::Schema.define(version: 20160709065922) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: :cascade do |t|
    t.string "name"
  end

  create_table "series", force: :cascade do |t|
    t.string  "name"
    t.integer "group_id"
  end

  add_index "series", ["group_id"], name: "index_series_on_group_id", using: :btree

  create_table "specifications", force: :cascade do |t|
    t.string  "name"
    t.text    "operating_system"
    t.text    "optical_device"
    t.text    "audio"
    t.integer "series_id"
  end

  add_index "specifications", ["series_id"], name: "index_specifications_on_series_id", using: :btree

  add_foreign_key "series", "groups"
  add_foreign_key "specifications", "series"
end
