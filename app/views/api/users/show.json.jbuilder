json.(@client, :id, :firebase_uid, :username, :phone_number, :email, :avatar_medium_id, :avatar_url, :is_banned, :created_at, :updated_at)
json.avatar_medium Medium.find(@client[:avatar_medium_id]) if @client[:avatar_medium_id]
