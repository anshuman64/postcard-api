require 'firebase_token_verifier'

class ApplicationController < ActionController::API
  FIREBASE_PROJECT_ID = 'insiya-mobile'

  @@verifier = FirebaseTokenVerifier.new(FIREBASE_PROJECT_ID)

  def decode_token(firebase_jwt)
    decoded_firebase_jwt, error = @@verifier.decode(firebase_jwt, nil)

    if decoded_firebase_jwt.nil?
      return nil, error
    end

    return decoded_firebase_jwt['user_id'], nil
  end

  def decode_token_and_find_user(firebase_jwt)
    decoded_firebase_jwt, error = @@verifier.decode(firebase_jwt, nil)

    if decoded_firebase_jwt.nil?
      return nil, error
    end

    return User.find_by_firebase_uid(decoded_firebase_jwt['user_id']), nil
  end
end
