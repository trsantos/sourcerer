class AddSubscriptionsUpdatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscription_updated_at, :datetime
  end
end
