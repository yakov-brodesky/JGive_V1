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

ActiveRecord::Schema[8.1].define(version: 2026_06_17_230000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.integer "baseline_donor_count", default: 0, null: false
    t.bigint "baseline_raised_amount_cents", default: 0, null: false
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.string "currency", default: "ILS", null: false
    t.bigint "goal_amount_cents", null: false
    t.bigint "organization_id", null: false
    t.text "story", null: false
    t.string "subtitle", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_campaigns_on_organization_id"
  end

  create_table "donations", force: :cascade do |t|
    t.bigint "amount_cents", null: false
    t.bigint "campaign_id", null: false
    t.datetime "created_at", null: false
    t.string "dedication_honoree"
    t.text "dedication_message"
    t.string "dedication_recipient_email"
    t.string "dedication_recipient_name"
    t.string "dedication_type"
    t.string "display_preference", default: "full_name", null: false
    t.string "donor_email", null: false
    t.string "donor_name"
    t.text "note"
    t.string "recurrence", default: "one_time", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "status"], name: "index_donations_on_campaign_id_and_status"
    t.index ["campaign_id"], name: "index_donations_on_campaign_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "category"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.string "phone"
    t.string "registration_number"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  add_foreign_key "campaigns", "organizations"
  add_foreign_key "donations", "campaigns"
end
