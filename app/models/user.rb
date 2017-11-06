class User < ApplicationRecord
  validates :phone_number, :session_token, presence: true
  validates :phone_number, uniqueness: true

  # validates :password, length: { minimum: 6, allow_nil: true }

  # attr_reader :password

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

  # after_initialize :ensure_session_token
  #
  # def self.find_by_credentials(username, password)
  #   user = User.find_by_username(username)
  #   return nil unless user && user.valid_password?(password)
  #   user
  # end
  #
  # def password=(password)
  #   @password = password
  #   self.password_digest = BCrypt::Password.create(password)
  # end
  #
  # def valid_password?(password)
  #   BCrypt::Password.new(self.password_digest).is_password?(password)
  # end
  #
  # def reset_token!
  #   self.session_token = SecureRandom.urlsafe_base64(16)
  #   self.save!
  #   self.session_token
  # end
  #
  # private
  #
  # def ensure_session_token
  #   self.session_token ||= SecureRandom.urlsafe_base64(16)
  # end
end
