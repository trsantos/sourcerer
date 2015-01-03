class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.text :title
      t.text :feed_url
      t.text :site_url

      t.timestamps null: false
    end
    add_index :feeds, :feed_url, unique: true
  end
end
