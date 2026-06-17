class CreateDonations < ActiveRecord::Migration[8.1]
  def change
    create_table :donations do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :donor_name
      t.string :donor_email, null: false
      t.bigint :amount_cents, null: false
      t.string :recurrence, null: false, default: "one_time"
      t.string :display_preference, null: false, default: "full_name"
      t.text :dedication_message
      t.text :note
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :donations, [ :campaign_id, :status ]
  end
end
