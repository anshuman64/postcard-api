require 'firebase_token_verifier'
require 'one_signal'
require 'twilio-ruby'

class ApplicationController < ActionController::API
  FIREBASE_PROJECT_ID = 'insiya-mobile'

  @@twilio_client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])
  @@verifier = FirebaseTokenVerifier.new(FIREBASE_PROJECT_ID)

  def decode_token(firebase_jwt)
    decoded_firebase_jwt, error_msg = @@verifier.decode(firebase_jwt, nil)

    if error_msg
      return nil, error_msg
    end

    return decoded_firebase_jwt['user_id'], nil
  end

  def decode_token_and_find_user(firebase_jwt)
    decoded_firebase_jwt, error_msg = @@verifier.decode(firebase_jwt, nil)

    # Here we assume that either decoded_firebase_jwt or error_msg are nil
    # If there is an error_msg, we return immediately
    if error_msg
      return nil, error_msg
    end

    requester = User.find_by_firebase_uid(decoded_firebase_jwt['user_id'])

    if requester
      return requester, nil
    else
      return nil, 'Requester not found'
    end
  end

  # TODO: make this better for group messaging
  def create_notification(client_id, recipient_id, title, message, data)
    params = {
      app_id: ENV["ONE_SIGNAL_APP_ID"],
      contents: { en: message },
      ios_badgeType: 'Increase',
      ios_badgeCount: 1,
      android_led_color: '007aff',
      android_accent_color: '007aff',
      filters: [{"field": "tag", "key": "user_id", "relation": "=", "value": recipient_id.to_s}],
      data: data,
      headings: title,
      android_group: client_id
    }

    begin
      response = OneSignal::Notification.create(params: params, opts: { auth_key: ENV["ONE_SIGNAL_AUTH_KEY"] })
      notification_id = JSON.parse(response.body)["id"]
    rescue OneSignal::OneSignalError => e
      puts "--- OneSignalError  :"
      puts "-- message : #{e.message}"
      puts "-- status : #{e.http_status}"
      puts "-- body : #{e.http_body}"
    end
  end

  def send_twilio_sms(phone_number, message)
    begin
      # Debug Test: uncomment for production
      message = @@twilio_client.messages.create(
        body: message,
        to:   phone_number,
        from: "+14088831259"
      )
    rescue Twilio::REST::RestError => e
      puts e.message
    end
  end

  def get_sms_start_string(client)
    if client[:full_name]
      return "Your friend " + client[:full_name]
    elsif client[:username]
      return "User \"" + client[:username] + "\""
    else
      return "Someone"
    end
  end

  def find_or_create_contact_user(client_id, phone_number)
    def create_friendship(client_id, user)
      friendship = Friendship.new({ requester_id: client_id, requestee_id: user.id, status: 'ACCEPTED' })

      if friendship.save
        return user, nil
      else
        return nil, friendship.errors.full_messages
      end
    end

    user = User.find_by_phone_number(phone_number)
    if user
      friendship = Friendship.find_by_requester_id_and_requestee_id(client_id, user.id)
      if friendship
        return user, nil
      else
        create_friendship(client_id, user)
      end
    else
      user = User.new({ phone_number: phone_number })
      if user.save
        create_friendship(client_id, user)
      else
        return nil, user.errors.full_messages
      end
    end
  end

  def send_pusher_group_to_grouplings(group, exempt_user_ids, pusher_type, client)
    pusher_group = group.as_json

    group.groupling_users.where('user_id NOT IN (?) and firebase_uid IS NOT NULL', exempt_user_ids).each do |user|
      pusher_group[:users] = group.groupling_users.where('user_id != ?', user.id).as_json
      Pusher.trigger('private-' + user.id.to_s, pusher_type, { group: pusher_group })

      if pusher_type == 'receive-group'
        create_notification(client.id, user.id, nil, client.username + ' added you to a group.', { type: pusher_type })
      end
    end

    return pusher_group
  end

  def get_pusher_message(message, client_id)
    pusher_message = message.as_json
    pusher_message[:medium] = message.medium

    message_post = message.post
    if message_post
      pusher_message[:post] = message_post.as_json
      pusher_message[:post][:num_likes] = message_post.likes.count
      pusher_message[:post][:is_liked_by_client] = message_post.likes.where('user_id = ?', client_id).present?

      pusher_message[:post][:num_flags] = message_post.flags.count
      pusher_message[:post][:is_flagged_by_client] = message_post.flags.where('user_id = ?', client_id).present?

      pusher_message[:post][:media] = message_post.media
    end

    return pusher_message
  end

  def get_message_notification_preview(message)
    if message.body
      message_preview = message.body
    else
      message_preview = 'Sent you an image.'
    end

    return message_preview
  end

end
