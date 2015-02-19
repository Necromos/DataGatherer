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

ActiveRecord::Schema.define(version: 20150219093203) do

  create_table "personal_data", force: true do |t|
    t.integer  "age"
    t.string   "nationality"
    t.string   "living_country"
    t.boolean  "health_issues"
    t.boolean  "chronic_diseases"
    t.boolean  "smoker"
    t.boolean  "alcoholic"
    t.boolean  "druggy"
    t.boolean  "disabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sex"
    t.boolean  "psychotropic"
  end

  create_table "self_esteems", force: true do |t|
    t.integer  "personal_datum_id"
    t.integer  "alcohol"
    t.integer  "tabacco"
    t.integer  "drugs"
    t.integer  "walking_time_per_day"
    t.integer  "jogging_time_per_day"
    t.integer  "gym_workout_time_per_day"
    t.integer  "swimming_time_per_day"
    t.integer  "wholesome_food_per_day"
    t.integer  "junk_food_per_day"
    t.string   "weather"
    t.string   "season"
    t.integer  "self_esteem"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
