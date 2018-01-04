require 'firebase_token_verifier'
require 'aws_token_verifier'

class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception

  FIREBASE_PROJECT_ID  = 'insiya-mobile'
  AWS_IDENTITY_POOL_ID = 'us-east-1:b0ea4b39-a029-4417-9457-8ec4b4f20b2d'

  @@verifier     = FirebaseTokenVerifier.new(FIREBASE_PROJECT_ID)
  @@aws_verifier = AwsTokenVerifier.new(AWS_IDENTITY_POOL_ID)

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

  def get_aws_token(user_id, firebase_jwt)
    identity_id, token = @@aws_verifier.get_token(user_id, firebase_jwt)

    return identity_id, token
  end
end
