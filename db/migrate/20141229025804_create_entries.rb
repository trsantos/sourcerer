class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.text :title
      t.text :description
      t.datetime :pub_date
      t.datetime :fetch_date
      t.text :url
      t.references :feed, index: true

      t.timestamps null: false
    end
    add_foreign_key :entries, :feeds
  end
end
