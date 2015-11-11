class CreateCachedImages < ActiveRecord::Migration
  def change
    create_table :cached_images do |t|
      t.belongs_to :feed, index: true
      t.text :entry_url
      t.text :image

      t.timestamps null: false
    end
    add_index :cached_images, :entry_url, unique: true
  end
end
