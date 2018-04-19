class User < ApplicationRecord
  validates :firebase_uid, presence: true
  validates :firebase_uid, :username, :email, :phone_number, uniqueness: { allow_blank: true, case_sensitive: false }

  has_many(:posts, class_name: :Post, foreign_key: :author_id, primary_key: :id, dependent: :destroy)

  has_many(:likes, class_name: :Like, foreign_key: :user_id, primary_key: :id, dependent: :destroy)
  has_many(:liked_posts, through: :likes, source: :post)

  has_many(:flags, class_name: :Flag, foreign_key: :user_id, primary_key: :id, dependent: :destroy)
  has_many(:flagged_posts, through: :flags, source: :post)

  has_many(:blocks_as_blocker, class_name: :Block, foreign_key: :blocker_id, primary_key: :id, dependent: :destroy)
  has_many(:blocks_as_blockee, class_name: :Block, foreign_key: :blockee_id, primary_key: :id, dependent: :destroy)
  has_many(:blockers, through: :blocks_as_blockee, source: :blocker)
  has_many(:blockees, through: :blocks_as_blocker, source: :blockee)

  has_many(:follows_as_follower, class_name: :Follow, foreign_key: :follower_id, primary_key: :id, dependent: :destroy)
  has_many(:follows_as_followee, class_name: :Follow, foreign_key: :followee_id, primary_key: :id, dependent: :destroy)
  has_many(:followers, through: :follows_as_followee, source: :follower)
  has_many(:followees, through: :follows_as_follower, source: :followee)

  has_many(:friendships_as_requester, class_name: :Friendship, foreign_key: :requester_id, primary_key: :id, dependent: :destroy)
  has_many(:friendships_as_requestee, class_name: :Friendship, foreign_key: :requestee_id, primary_key: :id, dependent: :destroy)
  has_many(:friends_as_requester, through: :friendships_as_requester, source: :requestee)
  has_many(:friends_as_requestee, through: :friendships_as_requestee, source: :requester)

  has_many(:received_shares, class_name: :Share, foreign_key: :recipient_id, primary_key: :id, dependent: :destroy)
  has_many(:received_posts, through: :received_shares, source: :post)

  has_many(:messages, class_name: :Message, foreign_key: :author_id, primary_key: :id, dependent: :destroy)

  has_many(:circles, class_name: :Circle, foreign_key: :creator_id, primary_key: :id, dependent: :destroy)
end
