class DatatypesReview < ActiveRecord::Migration
  def change
    change_column :entries, :title, :string
    change_column :entries, :url, :string
    change_column :entries, :image, :string
    change_column :feeds, :title, :string
    change_column :feeds, :feed_url, :string
    change_column :feeds, :site_url, :string
    change_column :feeds, :logo, :string
    change_column :subscriptions, :title, :string
    change_column :subscriptions, :site_url, :string
  end
end
