class Friendship < ApplicationRecord
  VALID_STATUSES = ['REQUESTED', 'ACCEPTED']

  validates :requester_id, :requestee_id, :status, presence: true
  validates :status, inclusion: { in: VALID_STATUSES }

  belongs_to(:requester, class_name: :User, foreign_key: :requester_id, primary_key: :id)

  belongs_to(:requestee, class_name: :User, foreign_key: :requestee_id, primary_key: :id)

  has_many(:messages, class_name: :Message, foreign_key: :friendship_id, primary_key: :id, dependent: :destroy)

  def self.find_friendship(user1_id, user2_id)
    Friendship.find_by_requester_id_and_requestee_id(user1_id, user2_id) || Friendship.find_by_requester_id_and_requestee_id(user2_id, user1_id)
  end

  def self.query_friends(user)
    friends = user.friends_as_requester.where('status = ? and firebase_uid IS NOT NULL', 'ACCEPTED') | user.friends_as_requestee.where('status = ? and firebase_uid IS NOT NULL', 'ACCEPTED')

    sort_friends_by_recent_messages(user.id, friends)
  end

  def self.query_sent_requests(user)
    user.friends_as_requester.where('status = ? and firebase_uid IS NOT NULL', 'REQUESTED')
  end

  def self.query_received_requests(user)
    user.friends_as_requestee.where('status = ? and firebase_uid IS NOT NULL', 'REQUESTED')
  end

  def self.query_friends_from_contacts(client, contacts)
    friend_ids = client.friends_as_requester.ids + client.friends_as_requestee.ids + [client.id]

    User.where('phone_number IN (?) and id NOT IN (?) and firebase_uid IS NOT NULL', contacts, friend_ids)
  end

  private

  def self.sort_friends_by_recent_messages(user_id, friends)
    friends.sort_by! do |friend|
      friendship = Friendship.find_friendship(user_id, friend.id)

      last_message = friendship.messages.last
      if last_message
        last_message.created_at
      else
        friendship.created_at
      end
    end

    friends.reverse
  end

end
