json.(@group, :id, :owner_id, :name, :created_at, :updated_at)
json.users @group.groupling_users.where('user_id != ?', @client.id)

json.peek_message do
  message = @group.messages.last

  if message
    json.(message, :id, :body, :author_id, :friendship_id, :group_id, :post_id, :created_at, :updated_at)

    json.author do
      json.(message.author, :id, :firebase_uid, :username, :phone_number, :email, :avatar_medium_id, :is_banned, :created_at, :updated_at)
      json.avatar_medium Medium.find(message.author[:avatar_medium_id]) if message.author[:avatar_medium_id]
    end

  end
end
