class RemoveValidationForFirbaseUidInUsersTable < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :firebase_uid, :string, :null => true
  end
end
