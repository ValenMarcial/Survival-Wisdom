# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_240_515_212_628) do
  create_table 'bars', force: :cascade do |t|
    t.string 'name_bar'
    t.integer 'value'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'guides', force: :cascade do |t|
    t.string 'title'
    t.string 'rute_content'
    t.integer 'skill_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['skill_id'], name: 'index_guides_on_skill_id'
  end

  create_table 'options', force: :cascade do |t|
    t.integer 'question_id'
    t.string 'description'
    t.json 'effects'
    t.index ['question_id'], name: 'index_options_on_question_id'
  end

  create_table 'questions', force: :cascade do |t|
    t.string 'statement'
    t.string 'typeCard'
    t.integer 'leftclicks', default: 0
    t.integer 'rightclicks', default: 0
  end

  create_table 'skills', force: :cascade do |t|
    t.string 'name'
    t.string 'description'
    t.string 'dificulty'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'stats', force: :cascade do |t|
    t.integer 'days'
    t.integer 'user_id'
    t.index ['user_id'], name: 'index_stats_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'username'
    t.string 'nickname'
    t.string 'password'
    t.integer 'coins'
    t.integer 'admin'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_foreign_key 'guides', 'skills'
  add_foreign_key 'options', 'questions'
  add_foreign_key 'stats', 'users'
end
