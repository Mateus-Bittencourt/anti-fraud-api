# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_12_09_175142) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "card_number", null: false
    t.boolean "blocked", default: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_number"], name: "index_cards_on_card_number", unique: true
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.integer "device_id", null: false
    t.bigint "user_id", null: false
    t.boolean "blocked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_devices_on_device_id", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.integer "merchant_id", null: false
    t.boolean "blocked", default: false
    t.integer "chargeback_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_merchants_on_merchant_id", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "transaction_id", null: false
    t.bigint "merchant_id", null: false
    t.bigint "user_id", null: false
    t.bigint "device_id"
    t.bigint "card_id", null: false
    t.datetime "transaction_date", null: false
    t.float "transaction_amount", null: false
    t.string "recommendation", null: false
    t.boolean "chargeback", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_transactions_on_card_id"
    t.index ["device_id"], name: "index_transactions_on_device_id"
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id"
    t.index ["transaction_id"], name: "index_transactions_on_transaction_id", unique: true
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "blocked", default: false
    t.integer "chargeback_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_users_on_user_id", unique: true
  end

  add_foreign_key "cards", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "transactions", "cards"
  add_foreign_key "transactions", "devices"
  add_foreign_key "transactions", "merchants"
  add_foreign_key "transactions", "users"
end
