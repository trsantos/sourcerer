class RemoveFetchingFromUsers < ActiveRecord::Migration
  def change
    remove_column :feeds, :fetching
  end
end
