require 'firebase_token_verifier'
require 'one_signal'

class ApplicationController < ActionController::API
  FIREBASE_PROJECT_ID = 'insiya-mobile'

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

  def create_notification(recipient, message, data)
    params = {
      app_id: ENV["ONE_SIGNAL_APP_ID"],
      contents: { en: message },
      ios_badgeType: 'Increase',
      ios_badgeCount: 1,
      android_led_color: '007aff',
      android_accent_color: '007aff',
      filters: [{"field": "tag", "key": "user_id", "relation": "=", "value": recipient.id.to_s}],
      data: data
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
end
