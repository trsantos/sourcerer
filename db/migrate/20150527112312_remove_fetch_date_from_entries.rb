class RemoveFetchDateFromEntries < ActiveRecord::Migration
  def change
    remove_column :entries, :fetch_date, :datetime
  end
end
