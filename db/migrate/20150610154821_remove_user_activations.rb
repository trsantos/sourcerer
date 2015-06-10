class RemoveUserActivations < ActiveRecord::Migration
  def change
    remove_column :users, :activation_digest
    remove_column :users, :activated
    remove_column :users, :activated_at
  end
end
