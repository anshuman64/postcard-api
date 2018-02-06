json.array! @users do |user|
  json.(user, :id, :username, :avatar_url)

  json.is_user_followed_by_client user.followers.where('follower_id = ?', @client.id).present?
end
