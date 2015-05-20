class AddIndexToTopicSubscriptions < ActiveRecord::Migration
  def change
    add_index :topic_subscriptions, [:user_id, :topic_id], unique: true
  end
end
