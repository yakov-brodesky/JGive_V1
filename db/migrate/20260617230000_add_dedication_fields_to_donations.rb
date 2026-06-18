class AddDedicationFieldsToDonations < ActiveRecord::Migration[8.1]
  def change
    add_column :donations, :dedication_type, :string
    add_column :donations, :dedication_honoree, :string
    add_column :donations, :dedication_recipient_name, :string
    add_column :donations, :dedication_recipient_email, :string
  end
end
