class AddIndexToEntriesTitle < ActiveRecord::Migration
  def change
    add_index :entries, :title
  end
end
