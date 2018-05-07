json.array! @users do |user|
  json.(user, :id, :firebase_uid, :username, :phone_number, :email, :avatar_medium_id, :is_banned, :created_at, :updated_at)

  json.avatar_medium Medium.find(user[:avatar_medium_id]) if user[:avatar_medium_id]
  json.is_user_blocked_by_client user.blockers.where('blocker_id = ?', @client.id).present?

  friendship = Friendship.find_friendship(@client.id, user.id)
  if friendship
    json.peek_message do
      message = friendship.messages.last

      if message
        json.(message, :id, :body, :author_id, :friendship_id, :group_id, :post_id, :created_at, :updated_at)
      end

    end
  end
end
