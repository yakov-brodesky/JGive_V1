class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :title, null: false
      t.string :subtitle, null: false
      t.string :cover_image_url
      t.bigint :goal_amount_cents, null: false
      t.bigint :baseline_raised_amount_cents, null: false, default: 0
      t.integer :baseline_donor_count, null: false, default: 0
      t.string :currency, null: false, default: "ILS"
      t.text :story, null: false

      t.timestamps
    end
  end
end
