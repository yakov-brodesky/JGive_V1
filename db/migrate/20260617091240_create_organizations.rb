class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :category
      t.string :city
      t.string :registration_number
      t.string :email
      t.string :phone
      t.string :website

      t.timestamps
    end
  end
end
