class Circle < ApplicationRecord
  validates :creator_id, :name, presence: true
  validates :name, uniqueness: { scope: :creator_id }

  belongs_to(:creator, class_name: :User, foreign_key: :creator_id, primary_key: :id)

  has_many(:circlings, class_name: :Circling, foreign_key: :circle_id, primary_key: :id, dependent: :destroy)
  has_many(:circling_users, through: :circlings, source: :user)
  has_many(:circling_groups, through: :circlings, source: :group)
end
