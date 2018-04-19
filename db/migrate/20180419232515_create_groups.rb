class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.integer :owner_id, null: false, index: true
      t.string  :name
      t.timestamps
    end

    execute "ALTER TABLE groups CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
