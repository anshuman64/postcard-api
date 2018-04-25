json.array! @posts do |post|
  json.(post, :id, :body, :author_id, :image_url, :is_public, :created_at, :updated_at)

  json.num_likes post.likes.count
  json.is_liked_by_client post.likes.where('user_id = ?', @client.id).present?

  json.num_flags post.flags.count
  json.is_flagged_by_client post.flags.where('user_id = ?', @client.id).present?

  user_recipient_ids = post.user_recipients.ids
  json.user_recipient_ids user_recipient_ids
  json.user_ids_with_client user_recipient_ids & [@client.id]

  group_recipient_ids = post.group_recipients.ids
  json.group_recipient_ids group_recipient_ids
  json.group_ids_with_client group_recipient_ids & @client.groups.ids

  json.author do
    json.(post.author, :id, :firebase_uid, :username, :phone_number, :email, :avatar_url, :is_banned, :created_at, :updated_at)
    json.is_user_followed_by_client post.author.followers.where('follower_id = ?', @client.id).present?
  end
end
