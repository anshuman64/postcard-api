json.array! @groups do |group|
  json.(group, :id, :owner_id, :name, :created_at, :updated_at)
  json.users group.groupling_users.where('user_id != ?', @client.id)

  json.peek_message do
    message = group.messages.last

    if message
      json.(message, :id, :body, :author_id, :friendship_id, :group_id, :post_id, :created_at, :updated_at)
    end
  end

end
