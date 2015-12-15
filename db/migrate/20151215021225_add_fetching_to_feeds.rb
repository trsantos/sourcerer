class AddFetchingToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :fetching, :boolean, default: true
  end
end
