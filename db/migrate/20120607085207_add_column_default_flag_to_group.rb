class AddColumnDefaultFlagToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :default_flag, :boolean, default: false
  end
end
