json.array! @users do |user|
  json.(user, :id, :firebase_uid, :username, :phone_number, :email, :avatar_url, :is_banned, :created_at, :updated_at)
end