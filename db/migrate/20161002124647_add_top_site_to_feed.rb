class AddTopSiteToFeed < ActiveRecord::Migration[5.0]
  def change
    add_column :feeds, :top_site, :boolean
  end
end
