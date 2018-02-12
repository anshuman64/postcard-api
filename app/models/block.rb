class Block < ApplicationRecord
  validates :blocker_id, :blockee_id, presence: true
  validates :blocker_id, uniqueness: { scope: :blockee_id }

  belongs_to(:blocker, class_name: :User, foreign_key: :blocker_id, primary_key: :id)

  belongs_to(:blockee, class_name: :User, foreign_key: :blockee_id, primary_key: :id)
end
