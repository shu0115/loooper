class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :user_id
      t.string :name
      t.string :status
      t.integer :life
      t.timestamp :last_done_at

      t.timestamps
    end
  end
end
