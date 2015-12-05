class RemoveFromtopicFromSubs < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :from_topic
  end
end
