class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.integer :user_id
      t.integer :item_id
      t.timestamp :done_at

      t.timestamps
    end
  end
end
