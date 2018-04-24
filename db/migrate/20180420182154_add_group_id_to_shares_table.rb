class AddGroupIdToSharesTable < ActiveRecord::Migration[5.1]
  def change
    add_column :shares, :group_id, :integer
    add_index :shares, :group_id

    change_column :shares, :recipient_id, :integer, :null => true
  end
end
