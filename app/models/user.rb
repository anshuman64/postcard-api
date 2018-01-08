class User < ApplicationRecord
  validates :firebase_uid, presence: true
  validates :firebase_uid, :username, :email, :phone_number, uniqueness: {allow_blank: true}
  #TODO: add length and character checks on username
  #TODO: adjust validations for case sensitivity, spaces, characters, etc.

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

  has_many(
    :liked_posts,
    through: :likes,
    source:  :post
  )
end
