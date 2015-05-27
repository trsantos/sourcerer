class RemoveSubscriptionsUpdatedAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :subscriptions_updated_at, :datetime
  end
end
