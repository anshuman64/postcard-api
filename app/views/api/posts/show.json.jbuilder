json.(@post, :id, :body, :author_id, :image_url, :created_at, :updated_at)

json.num_likes @post.likes.count
json.is_liked_by_client @post.likes.where('user_id = ?', @client.id).present?

json.num_flags @post.flags.count
json.is_flagged_by_client @post.flags.where('user_id = ?', @client.id).present?
