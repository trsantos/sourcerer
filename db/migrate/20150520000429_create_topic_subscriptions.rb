class CreateTopicSubscriptions < ActiveRecord::Migration
  def change
    create_table :topic_subscriptions do |t|
      t.belongs_to :user,  index: true
      t.belongs_to :topic, index: true

      t.timestamps null: false
    end
  end
end
