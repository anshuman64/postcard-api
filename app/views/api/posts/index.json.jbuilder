json.array! @posts do |post|
  json.(post, :id, :body, :author_id, :image_url, :is_public, :created_at, :updated_at)

  json.num_likes post.likes.count
  json.is_liked_by_client post.likes.where('user_id = ?', @client.id).present?

  json.num_flags post.flags.count
  json.is_flagged_by_client post.flags.where('user_id = ?', @client.id).present?

  json.author do
    json.(post.author, :id, :username, :avatar_url)
    json.is_user_followed_by_client post.author.followers.where('follower_id = ?', @client.id).present?
  end

  # BACKWARDS COMPATABILITY: Delete after v2.0.0 ships
  json.is_liked_by_user post.likes.where('user_id = ?', @client.id).present?
  json.is_flagged_by_user post.flags.where('user_id = ?', @client.id).present?

  json.author_username post.author.username
  json.author_avatar_url post.author.avatar_url
  json.is_author_followed_by_user post.author.followers.where('follower_id = ?', @client.id).present?
  # BACKWARDS COMPATABILITY: Delete after v2.0.0 ships
end
