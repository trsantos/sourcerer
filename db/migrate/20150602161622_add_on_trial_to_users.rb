class AddOnTrialToUsers < ActiveRecord::Migration
  def change
    add_column :users, :on_trial, :boolean, default: true
  end
end
