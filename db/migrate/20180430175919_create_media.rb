class CreateMedia < ActiveRecord::Migration[5.1]
  def change
    create_table :media do |t|
      t.integer :owner_id,    null: false, index: true
      t.string  :url,         null: false
      t.string  :medium_type, null: false,               default: 'PHOTO'
      t.integer :post_id,                  index: true
      t.integer :message_id,               index: true
      t.timestamps
    end
  end
end
