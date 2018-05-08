json.(@client, :id, :firebase_uid, :full_name, :username, :phone_number, :email, :avatar_medium_id, :is_banned, :last_login, :created_at, :updated_at)
json.avatar_medium Medium.find(@client[:avatar_medium_id]) if @client[:avatar_medium_id]
