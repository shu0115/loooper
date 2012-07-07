class AddColumnToItems < ActiveRecord::Migration
  def change
    add_column :items, :type, :string
    add_column :items, :deadline, :timestamp
    add_column :items, :done_user_id, :integer
  end
end
