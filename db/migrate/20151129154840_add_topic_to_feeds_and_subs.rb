class AddTopicToFeedsAndSubs < ActiveRecord::Migration
  def change
    add_reference :feeds, :topic, index: true
    add_reference :subscriptions, :topic, index: true
  end
end
