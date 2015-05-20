class FixUpdateSubscriptionsColumnName < ActiveRecord::Migration
  def change
    rename_column :users, :subscription_updated_at, :subscriptions_updated_at
  end
end
