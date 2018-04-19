class CreateCircles < ActiveRecord::Migration[5.1]
  def change
    create_table :circles do |t|
      t.integer :creator_id, null: false, index: true
      t.string  :name,       null: false
      t.timestamps
    end

    execute "ALTER TABLE circles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
