json.array! @users do |user|
  json.(user, :id, :firebase_uid, :username, :phone_number, :email, :avatar_medium_id, :avatar_url, :is_banned, :created_at, :updated_at)

  json.avatar_medium Medium.find(user[:avatar_medium_id]) if user[:avatar_medium_id]

  json.is_user_followed_by_client user.followers.where('follower_id = ?', @client.id).present? # NOTE: Follows are deprecated
  json.is_user_blocked_by_client user.blockers.where('blocker_id = ?', @client.id).present?

  friendship = Friendship.find_friendship(@client.id, user.id)

  if friendship
    json.peek_message do
      message = friendship.messages.last

      if message
        json.(message, :id, :body, :author_id, :image_url, :friendship_id, :post_id, :created_at, :updated_at)

        if message.post
          json.post do
            json.(message.post, :id, :body, :author_id, :image_url, :is_public, :created_at, :updated_at)

            json.num_likes message.post.likes.count
            json.is_liked_by_client message.post.likes.where('user_id = ?', @client.id).present?

            json.num_flags message.post.flags.count
            json.is_flagged_by_client message.post.flags.where('user_id = ?', @client.id).present?
          end
        end

      end
    end
  end
end
