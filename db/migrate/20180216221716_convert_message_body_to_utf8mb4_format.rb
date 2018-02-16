class ConvertMessageBodyToUtf8mb4Format < ActiveRecord::Migration[5.1]
  def change
    execute "ALTER TABLE messages CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
