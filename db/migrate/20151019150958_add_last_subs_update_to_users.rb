class AddLastSubsUpdateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscriptions_updated_at, :datetime
  end
end
