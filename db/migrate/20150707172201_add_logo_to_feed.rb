class AddLogoToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :logo, :text
  end
end
