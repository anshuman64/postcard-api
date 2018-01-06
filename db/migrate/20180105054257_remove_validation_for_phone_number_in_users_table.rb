class RemoveValidationForPhoneNumberInUsersTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :phone_number
    add_column    :users, :phone_number, :string
  end
end
