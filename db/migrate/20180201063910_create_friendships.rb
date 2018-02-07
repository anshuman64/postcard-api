class CreateFriendships < ActiveRecord::Migration[5.1]
  def change
    create_table :friendships do |t|
      t.integer :requester_id, null: false, index: true
      t.integer :requestee_id, null: false, index: true
      t.string  :status,       null: false, default: 'REQUESTED'
      t.timestamps
    end
  end
end
