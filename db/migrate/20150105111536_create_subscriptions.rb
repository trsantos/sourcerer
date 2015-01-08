class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :feed_id
      t.text :title
      t.text :site_url
      t.datetime :visited_at
      t.boolean :starred, default: false

      t.timestamps null: false
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, :feed_id
    add_index :subscriptions, [:user_id, :feed_id], unique: true
  end
end
