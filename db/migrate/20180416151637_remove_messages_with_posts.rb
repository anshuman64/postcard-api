class RemoveMessagesWithPosts < ActiveRecord::Migration[5.1]
  def change
    Message.where("post_id IS NOT NULL").delete_all
    remove_column :messages, :post_id
  end
end
