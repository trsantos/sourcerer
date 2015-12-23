class RemoveLastActivityFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_activity
  end
end
