class RemoveIndexFromCachedImages < ActiveRecord::Migration
  def change
    remove_index :cached_images, name: 'index_cached_images_on_entry_url'
  end
end
