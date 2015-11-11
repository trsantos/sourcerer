class AddIndexToCachedImages < ActiveRecord::Migration
  def change
    add_index :cached_images, :entry_url
    add_index :cached_images, [:feed_id, :entry_url], unique: true
  end
end
