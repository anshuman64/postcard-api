class Friendship < ApplicationRecord
  VALID_STATUSES = ['REQUESTED', 'ACCEPTED']

  validates :requester_id, :requestee_id, :status, presence: true
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

  def self.find_friendship(user1_id, user2_id)
    Friendship.find_by_requester_id_and_requestee_id(user1_id, user2_id) || Friendship.find_by_requester_id_and_requestee_id(user2_id, user1_id)
  end

  def self.query_friends(user)
    user.friendships_as_requester.where(status: 'ACCEPTED') |
    user.friendships_as_requestee.where(status: 'ACCEPTED')

    User.joins(:friendships_as_requestee).where('requester_id = ?', user.id) |
    User.joins(:friendships_as_requester).where('requestee_id = ?', user.id)

    user.friends_as_requester | user.friends_as_requestee
  end
end
