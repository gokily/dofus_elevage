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

ActiveRecord::Schema.define(version: 2019_06_14_100032) do

  create_table "mounts", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.string "color"
    t.integer "reproduction"
    t.string "sex"
    t.boolean "pregnant"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "father_id"
    t.integer "mother_id"
    t.integer "current_spouse_id"
    t.string "type"
    t.index ["father_id", "mother_id"], name: "index_mounts_on_father_id_and_mother_id"
    t.index ["father_id"], name: "index_mounts_on_father_id"
    t.index ["mother_id"], name: "index_mounts_on_mother_id"
    t.index ["user_id", "created_at"], name: "index_mounts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_mounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "server"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
