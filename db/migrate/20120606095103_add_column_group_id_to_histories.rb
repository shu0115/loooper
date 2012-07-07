class AddColumnGroupIdToHistories < ActiveRecord::Migration
  def change
    add_column :histories, :group_id, :integer
  end
end
