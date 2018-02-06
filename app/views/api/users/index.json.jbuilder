json.array! @users do |user|
  json.(user, :id, :firebase_uid, :username, :phone_number, :email, :avatar_url, :is_banned, :created_at, :updated_at)

  json.is_user_followed_by_client user.followers.where('follower_id = ?', @client.id).present?
end
