class DropNextFeedsTable < ActiveRecord::Migration
  def change
    drop_table :next_feeds
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
