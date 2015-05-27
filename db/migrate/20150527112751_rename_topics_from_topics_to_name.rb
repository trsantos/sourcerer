class RenameTopicsFromTopicsToName < ActiveRecord::Migration
  def change
    rename_column :topics, :topic, :name
  end
end
