class AddAvatarMediumIdToUsersTable < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avatar_medium_id, :integer
    add_index :users,  :avatar_medium_id
  end
end
