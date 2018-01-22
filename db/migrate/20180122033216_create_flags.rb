class CreateFlags < ActiveRecord::Migration[5.1]
  def change
    create_table :flags do |t|
      t.integer :user_id, null: false, index: true
      t.integer :post_id, null: false, index: true
      t.timestamps
    end
  end
end
