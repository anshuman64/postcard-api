class AddIsPublicToPostsTable < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :is_public, :boolean, null: false, default: false

    Post.find_each do |post|
      post.is_public = true
      post.save!
    end
  end
end
