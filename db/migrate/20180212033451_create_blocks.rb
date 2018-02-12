class CreateBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :blocks do |t|
      t.integer :blocker_id, null: false, index: true
      t.integer :blockee_id, null: false, index: true
      t.timestamps
    end
  end
end
