class CreateShares < ActiveRecord::Migration[5.1]
  def change
    create_table :shares do |t|
      t.integer :recipient_id, null: false, index: true
      t.integer :post_id,      null: false, index: true
      t.timestamps
    end
  end
end
