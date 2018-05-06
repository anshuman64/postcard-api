class RemoveAvatarUrlFromUsersTableAndImageUrlFromPostsAndMessagesTables < ActiveRecord::Migration[5.1]
  def change
    remove_column :posts,    :image_url
    remove_column :messages, :image_url
    remove_column :users,    :avatar_url
  end
end
