json.array! @groups do |group|
  json.(group, :id, :owner_id, :name, :created_at, :updated_at)

  json.users group.groupling_users.where('user_id != ?', @client.id)

  json.peek_message do
    message = group.messages.last

    if message
      json.(message, :id, :body, :author_id, :image_url, :friendship_id, :group_id, :post_id, :created_at, :updated_at)

      json.author do
        json.(message.author, :id, :firebase_uid, :username, :phone_number, :email, :avatar_medium_id, :avatar_url, :is_banned, :created_at, :updated_at)
        json.avatar_medium Medium.find(message.author[:avatar_medium_id]) if message.author[:avatar_medium_id]
      end

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
