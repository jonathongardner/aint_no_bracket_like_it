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

ActiveRecord::Schema.define(version: 2019_01_02_231240) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tournament_match_ups", force: :cascade do |t|
    t.integer "game"
    t.bigint "top_tournament_team_id"
    t.bigint "bottom_tournament_team_id"
    t.integer "top_team_score"
    t.integer "bottom_team_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bottom_tournament_team_id"], name: "index_tournament_match_ups_on_bottom_tournament_team_id"
    t.index ["top_tournament_team_id"], name: "index_tournament_match_ups_on_top_tournament_team_id"
  end

  create_table "tournament_teams", force: :cascade do |t|
    t.bigint "team_id"
    t.integer "year"
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_tournament_teams_on_team_id"
    t.index ["year"], name: "index_tournament_teams_on_year"
  end

  add_foreign_key "tournament_match_ups", "tournament_teams", column: "bottom_tournament_team_id"
  add_foreign_key "tournament_match_ups", "tournament_teams", column: "top_tournament_team_id"
  add_foreign_key "tournament_teams", "teams"
end