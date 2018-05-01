json.(@message, :id, :body, :author_id, :image_url, :friendship_id, :group_id, :post_id, :created_at, :updated_at)


json.media @message.media

if @message.post
  json.post do
    json.(@message.post, :id, :body, :author_id, :image_url, :is_public, :created_at, :updated_at)

    json.num_likes @message.post.likes.count
    json.is_liked_by_client @message.post.likes.where('user_id = ?', @client.id).present?

    json.num_flags @message.post.flags.count
    json.is_flagged_by_client @message.post.flags.where('user_id = ?', @client.id).present?

    json.media @message.post.media
  end
end
