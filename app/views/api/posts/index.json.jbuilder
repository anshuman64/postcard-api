json.array! @posts do |post|
  json.(post, :id, :body, :author_id, :created_at, :updated_at)

  json.num_likes post.likes.count
  json.is_liked_by_client post.likes.where('user_id = ?', @client.id).present?

  json.num_flags post.flags.count
  json.is_flagged_by_client post.flags.where('user_id = ?', @client.id).present?

  json.media post.media

  user_recipient_ids = post.user_recipients.ids
  json.user_recipient_ids user_recipient_ids
  json.user_ids_with_client user_recipient_ids & [@client.id]

  group_recipient_ids = post.group_recipients.ids
  json.group_recipient_ids group_recipient_ids
  json.group_ids_with_client group_recipient_ids & @client.groups.ids

  json.author do
    json.(post.author, :id, :firebase_uid, :full_name, :username, :phone_number, :email, :avatar_medium_id, :is_banned, :last_login, :created_at, :updated_at)
    json.avatar_medium Medium.find(post.author[:avatar_medium_id]) if post.author[:avatar_medium_id]
  end
end
