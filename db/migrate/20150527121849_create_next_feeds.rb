class CreateNextFeeds < ActiveRecord::Migration
  def change
    create_table :next_feeds do |t|
      t.belongs_to :user, index: true
      t.integer   :feed_id

      t.timestamps null: false
    end
  end
end
