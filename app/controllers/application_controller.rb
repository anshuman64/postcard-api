require 'firebase_token_verifier'

class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception

  FIREBASE_PROJECT_ID = 'insiya-mobile'

  verifier = FirebaseTokenVerifier.new(FIREBASE_PROJECT_ID)

  def decode_token(firebase_jwt)
    verifer.decode(firebase_jwt, nil)
  end

  def decode_token_and_find_user(firebase_jwt)
    firebase_uid = verifer.decode(firebase_jwt, nil)

    User.find_by_firebase_uid(firebase_uid)
  end
end
