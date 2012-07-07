class AddColumnGroupIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :group_id, :integer
  end
end
