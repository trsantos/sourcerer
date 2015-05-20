class AddFromTopicAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :from_topic, :boolean, default: false
  end
end
