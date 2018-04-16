json.array! @messages do |message|
  json.(message, :id, :body, :author_id, :image_url, :friendship_id, :created_at, :updated_at)
end
