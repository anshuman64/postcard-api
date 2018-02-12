class Message < ApplicationRecord
  validates :body, :author_id, :friendship_id, presence: true

  belongs_to(:author, class_name: :User, foreign_key: :author_id, primary_key: :id)

  belongs_to(:friendship, class_name: :Friendship, foreign_key: :friendship_id, primary_key: :id)

  has_one(:post, class_name: :Post, foreign_key: :post_id, primary_key: :id)
end
