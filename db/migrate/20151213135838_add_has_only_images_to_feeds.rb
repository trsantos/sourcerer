class AddHasOnlyImagesToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :has_only_images, :boolean
  end
end
