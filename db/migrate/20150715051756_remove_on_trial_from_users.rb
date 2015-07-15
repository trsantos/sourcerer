class RemoveOnTrialFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :on_trial, :boolean
  end
end
