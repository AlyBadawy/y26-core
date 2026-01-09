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

ActiveRecord::Schema[8.1].define(version: 2026_01_05_142748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "affirmation_entries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_affirmation_entries_on_user_id"
  end

  create_table "books", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "author", null: false
    t.datetime "created_at", null: false
    t.date "finished_on"
    t.string "genre"
    t.text "notes"
    t.integer "rating"
    t.date "started_on"
    t.string "status", default: "to_read", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["genre"], name: "index_books_on_genre"
    t.index ["rating"], name: "index_books_on_rating"
    t.index ["status"], name: "index_books_on_status"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "gratitude_entries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_gratitude_entries_on_user_id"
  end

  create_table "journal_entries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "journaled_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "journaled_at"], name: "index_journal_entries_on_user_id_and_journaled_at"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "mood_entries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "status", default: 3, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "date"], name: "index_mood_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_mood_entries_on_user_id"
  end

  create_table "movies", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "genre"
    t.text "notes"
    t.integer "rating"
    t.string "status", default: "to_watch", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.date "watched_on"
    t.index ["genre"], name: "index_movies_on_genre"
    t.index ["rating"], name: "index_movies_on_rating"
    t.index ["status"], name: "index_movies_on_status"
    t.index ["user_id"], name: "index_movies_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address", null: false
    t.datetime "last_refreshed_at"
    t.integer "refresh_count", default: 0, null: false
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.boolean "revoked", default: false, null: false
    t.datetime "updated_at", null: false
    t.string "user_agent", null: false
    t.uuid "user_id", null: false
    t.index ["refresh_token"], name: "index_sessions_on_refresh_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sleep_hours_entries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "hours", default: 8, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "date"], name: "index_sleep_hours_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_sleep_hours_entries_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "bio"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "email_verification_token"
    t.datetime "email_verification_token_created_at"
    t.datetime "email_verified"
    t.string "first_name"
    t.string "last_name"
    t.string "new_email"
    t.datetime "password_changed_at"
    t.string "password_digest"
    t.string "phone"
    t.string "reset_password_token"
    t.datetime "reset_password_token_created_at"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "water_intake_entries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cups", default: 1, null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "date"], name: "index_water_intake_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_water_intake_entries_on_user_id"
  end

  create_table "weather_entries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "date"], name: "index_weather_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_weather_entries_on_user_id"
  end

  add_foreign_key "affirmation_entries", "users"
  add_foreign_key "books", "users"
  add_foreign_key "gratitude_entries", "users"
  add_foreign_key "journal_entries", "users"
  add_foreign_key "mood_entries", "users"
  add_foreign_key "movies", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sleep_hours_entries", "users"
  add_foreign_key "water_intake_entries", "users"
  add_foreign_key "weather_entries", "users"
end
