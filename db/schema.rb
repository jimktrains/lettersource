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

ActiveRecord::Schema.define(version: 20170210035413) do

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
    t.index ["path"], name: "categories_path_unique", unique: true, using: :btree
    t.index ["path"], name: "index_categories_on_path", using: :gist
  end

  create_table "categories_aliases", primary_key: ["categories_id", "alias"], force: :cascade do |t|
    t.text  "alias",         null: false
    t.ltree "categories_id", null: false
    t.index "alias gin_trgm_ops", name: "categories_alias_trgm", using: :gin
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
    t.text     "title",                      null: false
    t.text     "body",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "rendered_body"
    t.decimal  "spam_score"
    t.text     "spam_filters",  default: [],              array: true
    t.boolean  "public"
    t.index "((setweight(to_tsvector('english'::regconfig, COALESCE(title, ''::text)), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(body, ''::text)), 'B'::\"char\")))", name: "letters_body_ftidx", using: :gin
  end

  create_table "letters_hofr", primary_key: ["letter_id", "cd"], force: :cascade do |t|
    t.integer "letter_id", null: false
    t.text    "cd",        null: false
    t.index ["cd"], name: "letters_hofr_cd_idx", using: :btree
  end

  create_table "letters_senate", primary_key: ["letter_id", "state"], force: :cascade do |t|
    t.integer "letter_id", null: false
    t.text    "state",     null: false
    t.index ["state"], name: "letters_senate_state_pk", using: :btree
  end

  create_table "statefips", id: false, force: :cascade do |t|
    t.text "state",      null: false
    t.text "stusab"
    t.text "state_name"
    t.text "statens"
    t.index ["state"], name: "statefips_state_unique", unique: true, using: :btree
    t.index ["stusab"], name: "index_statefips_on_stusab", using: :btree
  end

  create_table "zip2cds", primary_key: "cd", id: :text, force: :cascade do |t|
    t.text "zcta5",              array: true
    t.text "state", null: false
    t.index ["state"], name: "zip2cds_state_idx", using: :btree
    t.index ["zcta5"], name: "zip2cds_zcta5_idx", using: :gin
  end

  add_foreign_key "categories_aliases", "categories", column: "categories_id", primary_key: "path", name: "categories_aliases_categories_id_fkey"
  add_foreign_key "letters_hofr", "letters", name: "letters_hofr_letter_id_fkey"
  add_foreign_key "letters_hofr", "zip2cds", column: "cd", primary_key: "cd", name: "letters_hofr_cd_fkey"
  add_foreign_key "letters_senate", "letters", name: "letters_senate_letter_id_fkey"
  add_foreign_key "letters_senate", "statefips", column: "state", primary_key: "state", name: "letters_senate_state_fkey"
end
