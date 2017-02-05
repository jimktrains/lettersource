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

ActiveRecord::Schema.define(version: 20170205051655) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "ltree"
  enable_extension "pg_trgm"

  create_table "categories", force: :cascade do |t|
    t.text     "name",         null: false
    t.boolean  "public"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.ltree    "path",         null: false
    t.text     "display_name"
    t.index "name gin_trgm_ops", name: "categories_name_trgm", using: :gin
    t.index ["path"], name: "index_categories_on_path", using: :gist
  end

  create_table "categories_letters", id: false, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "letter_id",   null: false
    t.index ["category_id"], name: "index_categories_letters_on_category_id", using: :btree
    t.index ["letter_id"], name: "index_categories_letters_on_letter_id", using: :btree
  end

# Could not dump table "congress_critters" because of following StandardError
#   Unknown type 'cc_type' for column 'position'

  create_table "letters", force: :cascade do |t|
    t.text     "title",         null: false
    t.text     "body",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "rendered_body"
    t.index "((setweight(to_tsvector('english'::regconfig, COALESCE(title, ''::text)), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(body, ''::text)), 'B'::\"char\")))", name: "letters_body_ftidx", using: :gin
  end

  create_table "statefips", force: :cascade do |t|
    t.text "state"
    t.text "stusab"
    t.text "state_name"
    t.text "statens"
    t.index ["stusab"], name: "index_statefips_on_stusab", using: :btree
  end

  create_table "zip2cd", primary_key: "zcta5", id: :text, force: :cascade do |t|
    t.text "state", array: true
    t.text "cd",    array: true
  end

  create_table "zip2cds", id: false, force: :cascade do |t|
    t.string "zipcode", limit: 5
    t.string "states",            array: true
    t.string "cds",               array: true
  end

end
