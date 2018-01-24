class CreateFollows < ActiveRecord::Migration[5.1]
  def change
    create_table :follows do |t|
      t.integer :follower_id, null: false, index: true
      t.integer :followee_id, null: false, index: true
      t.timestamps
    end
  end
end
