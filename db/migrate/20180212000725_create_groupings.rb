class CreateGroupings < ActiveRecord::Migration[5.1]
  def change
    create_table :groupings do |t|
      t.integer :participant_id,  null: false, index: true
      t.integer :conversation_id, null: false, index: true
      t.timestamps
    end
  end
end
