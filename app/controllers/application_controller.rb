require 'firebase_token_verifier'

class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception

  FIREBASE_PROJECT_ID = 'insiya-mobile'

  verifier = FirebaseTokenVerifier.new(FIREBASE_PROJECT_ID)

  define_method(:decode_token) do |firebase_jwt|
    verifier.decode(firebase_jwt, nil)
  end

  define_method(:decode_token_and_find_user) do |firebase_jwt|
    firebase_uid = verifier.decode(firebase_jwt, nil)["user_id"]

    User.find_by_firebase_uid(firebase_uid)
  end
end
