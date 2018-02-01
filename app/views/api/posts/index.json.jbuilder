json.array! @posts do |post|
  json.(post, :id, :body, :author_id, :image_url, :created_at, :updated_at)

  json.num_likes post.likes.count
  json.is_liked_by_user post.likes.where('user_id = ?', @client.id).present?

  json.num_flags post.flags.count
  json.is_flagged_by_user post.flags.where('user_id = ?', @client.id).present?

  json.is_author_followed_by_user post.author.followers.where('follower_id = ?', @client.id).present?

  json.author do
    json.(post.author, :id, :username, :avatar_url)
  end
end
