json.(@message, :id, :body, :author_id, :image_url, :friendship_id, :post_id, :created_at, :updated_at)

if @message.post
  json.post do
    json.(@message.post, :id, :body, :author_id, :image_url, :is_public, :created_at, :updated_at)
  end
end
