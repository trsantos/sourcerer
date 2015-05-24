class DropDelayedJobsTable < ActiveRecord::Migration
  def change
    drop_table :delayed_jobs
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
