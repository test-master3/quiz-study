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

ActiveRecord::Schema[7.1].define(version: 2025_06_20_022217) do
  create_table "answers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "content"
    t.boolean "from_gpt"
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "quiz_id", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["quiz_id"], name: "index_answers_on_quiz_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "answer"
    t.text "answer_text"
    t.text "quiz_question"
    t.text "quiz_choices"
    t.string "quiz_answer"
    t.text "analogy_text"
    t.string "abstraction_level"
    t.string "analogy_genre"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "quizzes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "quiz_text"
    t.boolean "send_to_line"
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.text "quiz_choices"
    t.string "quiz_link"
    t.index ["question_id"], name: "index_quizzes_on_question_id"
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "line_uid"
    t.boolean "line_linked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "line_link_token"
    t.datetime "line_link_token_sent_at"
    t.index ["line_link_token"], name: "index_users_on_line_link_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "quizzes"
  add_foreign_key "answers", "users"
  add_foreign_key "questions", "users"
  add_foreign_key "quizzes", "questions"
  add_foreign_key "quizzes", "users"
end
