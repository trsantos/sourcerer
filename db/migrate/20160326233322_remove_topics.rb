class RemoveTopics < ActiveRecord::Migration
  def change
    remove_column :feeds, :topic_id, :integer
    remove_column :subscriptions, :topic_id, :integer
    drop_table :topics
    drop_table :topics_users
  end
end
