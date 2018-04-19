class CreateCirclings < ActiveRecord::Migration[5.1]
  def change
    create_table :circlings do |t|
      t.integer :circle_id, null: false, index: true
      t.integer :user_id,   null: false, index: true
      t.timestamps
    end
  end
end
