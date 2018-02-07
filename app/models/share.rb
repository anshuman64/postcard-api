class Share < ApplicationRecord
  validates :recipient_id, :post_id, presence: true
  validates :post_id, uniqueness: { scope: :recipient_id }

  belongs_to(:recipient, class_name: :User, foreign_key: :recipient_id, primary_key: :id)

  belongs_to(:post, class_name: :Post, foreign_key: :post_id, primary_key: :id)
end
