class ChangeColumnStatusToItems < ActiveRecord::Migration
  def up
    change_column :items, :status, :string, default: ""
  end

  def down
    change_column :items, :status, :string, default: nil
  end
end
