class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.text    :body,      null: false
      t.integer :author_id, null: false, index: true
      t.timestamps
    end
  end
end
