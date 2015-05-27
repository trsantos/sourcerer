class AddIndexToSubscriptionsUpdated < ActiveRecord::Migration
  def change
    add_index :subscriptions, :updated
  end
end
