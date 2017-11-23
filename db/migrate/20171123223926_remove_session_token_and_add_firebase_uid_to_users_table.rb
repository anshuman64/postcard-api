class RemoveSessionTokenAndAddFirebaseUidToUsersTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :session_token
    add_column    :users, :firebase_uid, :string, null: false
    add_index     :users, :firebase_uid, unique: true
  end
end
