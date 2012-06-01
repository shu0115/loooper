class AddColumnArchiveAtToItems < ActiveRecord::Migration
  def change
    add_column :items, :archive_at, :timestamp
  end
end
