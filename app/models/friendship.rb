class Friendship < ApplicationRecord
  VALID_STATUSES = ['REQUESTED', 'ACCEPTED']

  validates :requester_id, :requestee_id, :status, presence: true
  validates :requester_id, uniqueness: { scope: :requestee_id }
  validates :status, inclusion: { in: VALID_STATUSES }

  belongs_to(
    :requester,
    class_name:  :User,
    foreign_key: :requester_id,
    primary_key: :id
  )

  belongs_to(
    :requestee,
    class_name:  :User,
    foreign_key: :requestee_id,
    primary_key: :id
  )
end
