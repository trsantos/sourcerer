class RemoveUnusedColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :remember_digest, :string
    remove_column :users, :admin, :boolean
    remove_column :users, :reset_digest, :string
    remove_column :users, :reset_sent_at, :datetime
  end
end
