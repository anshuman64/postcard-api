class AddAvatarUrlAndUsernameToUsersTable < ActiveRecord::Migration[5.1]
  def change
    add_column    :users, :avatar_url, :string
    add_column    :users, :username,   :string
    
    add_index     :users, :username, unique: true
  end
end
