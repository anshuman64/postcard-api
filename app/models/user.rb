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
    :follows_as_follower,
    class_name:  :Follow,
    foreign_key: :follower_id,
    primary_key: :id,
    dependent:   :destroy
  )

  has_many(
    :follows_as_followee,
    class_name:  :Follow,
    foreign_key: :followee_id,
    primary_key: :id,
    dependent:   :destroy
  )

  has_many(
    :liked_posts,
    through: :likes,
    source:  :post
  )

  has_many(
    :followers,
    through: :follows_as_followee,
    source:  :follower
  )

  has_many(
    :followees,
    through: :follows_as_follower,
    source:  :followee
  )
end
