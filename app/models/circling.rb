class Circling < ApplicationRecord
  validates :user_id, :circle_id, presence: true
  validates :circle_id, uniqueness: { scope: :user_id }

  belongs_to(:user, class_name: :User, foreign_key: :user_id, primary_key: :id)

  belongs_to(:circle, class_name: :Circle, foreign_key: :circle_id, primary_key: :id)
end
