class RemoveValidationForBodyInPostsTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :posts, :body
    add_column    :posts, :body, :string
  end
end
