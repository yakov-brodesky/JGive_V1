class AddDonationOptionToDonations < ActiveRecord::Migration[8.1]
  def change
    add_reference :donations, :donation_option, foreign_key: true
  end
end
