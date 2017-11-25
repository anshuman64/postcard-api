require 'firebase_token_verifier'

class User < ApplicationRecord
  FIREBASE_PROJECT_ID = 'insiya-mobile'

  validates :phone_number, :firebase_uid, presence: true
  validates :phone_number, uniqueness: true

  has_many(
    :posts,
    class_name:  :Post,
    foreign_key: :author_id,
    primary_key: :id,
    dependent:   :destroy
  )

  has_many(
    :likes,
    class_name:  :Like,
    foreign_key: :user_id,
    primary_key: :id,
    dependent:   :destroy
  )

  after_initialize :ensure_firebase_uid

  private

  def ensure_firebase_uid
    verifier = FirebaseTokenVerifier.new(FIREBASE_PROJECT_ID)

    # rsa_private = OpenSSL::PKey::RSA.generate 2048
    # rsa_public = rsa_private.public_key
    #
    #
    # encoded_token = verifier.encode(rsa_private)
    # puts encoded_token
    decoded_token = verifier.decode(encoded_token, rsa_public)
    puts decoded_token
  end
end
