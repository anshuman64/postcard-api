json.(@post, :id, :body, :author_id, :image_url, :created_at, :updated_at)
json.num_likes @post.likes.count
json.is_liked_by_user  @post.likes.where('user_id = ?', @requester.id).present?
