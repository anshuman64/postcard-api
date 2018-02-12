class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.text    :body,          null: false
      t.integer :author_id,     null: false, index: true
      t.integer :friendship_id, null: false, index: true
      t.integer :post_id,                    index: true
      t.timestamps
    end
  end
end
