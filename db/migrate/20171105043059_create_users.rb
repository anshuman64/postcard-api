class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :phone_number,  null: false
      t.string :session_token, null: false
      t.timestamps
    end

    add_index :users, :phone_number,  unique: true
    add_index :users, :session_token, unique: true
  end
end
