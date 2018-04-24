class CreateGrouplings < ActiveRecord::Migration[5.1]
  def change
    create_table :grouplings do |t|
      t.integer :group_id, null: false, index: true
      t.integer :user_id,  null: false, index: true
      t.timestamps
    end
  end
end
