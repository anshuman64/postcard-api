require 'firebase_token_verifier'

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
end
