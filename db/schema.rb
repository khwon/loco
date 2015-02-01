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

ActiveRecord::Schema.define(version: 20150201102439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

# Could not dump table "board_reads" because of following StandardError
#   Unknown type 'board_reads_status' for column 'status'

  create_table "boards", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "title"
    t.integer  "linked_board_id"
    t.integer  "alias_board_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.boolean  "is_dir"
    t.string   "name"
  end

  add_index "boards", ["alias_board_id"], name: "index_boards_on_alias_board_id", using: :btree
  add_index "boards", ["linked_board_id"], name: "index_boards_on_linked_board_id", using: :btree
  add_index "boards", ["name"], name: "index_boards_on_name", using: :btree
  add_index "boards", ["owner_id"], name: "index_boards_on_owner_id", using: :btree
  add_index "boards", ["parent_id"], name: "index_boards_on_parent_id", using: :btree

  create_table "fav_boards", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "fav_boards", ["board_id"], name: "index_fav_boards_on_board_id", using: :btree
  add_index "fav_boards", ["user_id", "board_id"], name: "index_fav_boards_on_user_id_and_board_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.integer  "board_id"
    t.integer  "parent_id"
    t.text     "content"
    t.integer  "writer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num"
    t.boolean  "highlighted", default: false
  end

  add_index "posts", ["board_id", "num"], name: "index_posts_on_board_id_and_num", unique: true, using: :btree
  add_index "posts", ["parent_id"], name: "index_posts_on_parent_id", using: :btree
  add_index "posts", ["writer_id"], name: "index_posts_on_writer_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "password_digest"
    t.string   "nickname"
    t.string   "realname"
    t.string   "sex"
    t.string   "email"
    t.string   "old_crypt_password"
    t.boolean  "is_active",          default: true
  end

  create_table "visitread_maxes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "board_id"
    t.integer  "num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "visitread_maxes", ["user_id", "board_id"], name: "index_visitread_maxes_on_user_id_and_board_id", using: :btree

  create_table "zap_boards", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "zap_boards", ["board_id"], name: "index_zap_boards_on_board_id", using: :btree
  add_index "zap_boards", ["user_id", "board_id"], name: "index_zap_boards_on_user_id_and_board_id", using: :btree

end
