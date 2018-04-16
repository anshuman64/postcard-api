json.array! @users do |user|
  json.(user, :id, :firebase_uid, :username, :phone_number, :email, :avatar_url, :is_banned, :created_at, :updated_at)

  json.is_user_followed_by_client user.followers.where('follower_id = ?', @client.id).present?
  json.is_user_blocked_by_client user.blockers.where('blocker_id = ?', @client.id).present?

  friendship = Friendship.find_friendship(@client.id, user.id)

  if friendship
    json.peek_message do
      message = friendship.messages.last

      if message
        json.(message, :id, :body, :author_id, :image_url, :friendship_id, :created_at, :updated_at)
      end
    end
  end
end
