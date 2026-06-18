class AddAllowsRecurringToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :allows_recurring, :boolean, default: false, null: false
  end
end
