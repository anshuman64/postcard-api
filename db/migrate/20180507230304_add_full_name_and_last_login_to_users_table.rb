class AddFullNameAndLastLoginToUsersTable < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :full_name,  :string
    add_column :users, :last_login, :datetime, null: false, default: Time.now, index: true
  end
end
