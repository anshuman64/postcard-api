json.array! @posts do |post|
  json.(post, :id, :body, :author_id, :created_at, :updated_at)
  json.num_likes = post.likes.count
end
