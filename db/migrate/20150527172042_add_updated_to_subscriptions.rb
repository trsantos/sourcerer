class AddUpdatedToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :updated, :boolean, default: true
  end
end
