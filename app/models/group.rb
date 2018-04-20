class Group < ApplicationRecord
  validates :owner_id, presence: true

  belongs_to(:owner, class_name: :User, foreign_key: :owner_id, primary_key: :id)

  has_many(:grouplings, class_name: :Groupling, foreign_key: :group_id, primary_key: :id, dependent: :destroy)
  has_many(:groupling_users, through: :grouplings, source: :user)

  has_many(:messages, class_name: :Message, foreign_key: :group_id, primary_key: :id, dependent: :destroy)
end
