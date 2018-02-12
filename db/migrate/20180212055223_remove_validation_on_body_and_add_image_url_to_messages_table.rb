class RemoveValidationOnBodyAndAddImageUrlToMessagesTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :messages, :body
    add_column    :messages, :body, :text
    add_column    :messages, :image_url, :string
  end
end
