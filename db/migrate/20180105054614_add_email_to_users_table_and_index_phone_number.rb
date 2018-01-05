class AddEmailToUsersTableAndIndexPhoneNumber < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email, :string

    add_index :users, :email,        unique: true
    add_index :users, :phone_number, unique: true
  end
end
