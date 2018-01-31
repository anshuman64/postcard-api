class ConvertPostBodyToTextAndutf8mb4Format < ActiveRecord::Migration[5.1]
  def change
    change_column :posts, :body, :text
    
    execute "ALTER TABLE posts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
