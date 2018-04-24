class AddGroupIdToMessagesTable < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :group_id, :integer
    add_index :messages, :group_id
    
    change_column :messages, :friendship_id, :integer, :null => true
  end
end
