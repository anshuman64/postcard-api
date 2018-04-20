class AddGroupIdToCirclingsTable < ActiveRecord::Migration[5.1]
  def change
    add_column :circlings, :group_id, :integer
    add_index :circlings, :group_id

    change_column :circlings, :user_id, :integer, :null => true
  end
end
