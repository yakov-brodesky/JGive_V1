class CreateDonationOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :donation_options do |t|
      t.references :campaign, null: false, foreign_key: true
      t.bigint :amount_cents, null: false
      t.string :label, null: false
      t.text :description
      t.integer :position, default: 0, null: false
      t.string :badge
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :donation_options, [ :campaign_id, :position ]
  end
end
