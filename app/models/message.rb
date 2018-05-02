class Message < ApplicationRecord
  DEFAULT_LIMIT    = 20
  DEFAULT_START_AT = 1

  validates :author_id, presence: true
  validate  :validate_message_ownership

  belongs_to(:author, class_name: :User, foreign_key: :author_id, primary_key: :id)

  belongs_to(:friendship, class_name: :Friendship, foreign_key: :friendship_id, primary_key: :id, optional: true)
  belongs_to(:group, class_name: :Group, foreign_key: :group_id, primary_key: :id, optional: true)

  belongs_to(:post, class_name: :Post, foreign_key: :post_id, primary_key: :id, optional: true)

  has_one(:medium, class_name: :Medium, foreign_key: :message_id, primary_key: :id, dependent: :destroy)

  def self.query_direct_messages(limit, start_at, client_id, user_id)
    friendship = Friendship.find_friendship(client_id, user_id)

    unless friendship
      return []
    end

    most_recent_message = friendship.messages.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_message ? most_recent_message.id + 1 : DEFAULT_START_AT)

    friendship.messages.where('id < ?', start_at).last(limit).reverse
  end


  def self.query_new_direct_messages(start_at, client_id, user_id)
    friendship = Friendship.find_friendship(client_id, user_id)

    unless friendship
      return []
    end

    most_recent_message = friendship.messages.last

    start_at ||= (most_recent_message ? most_recent_message.id : DEFAULT_START_AT)

    friendship.messages.where('id > ?', start_at).reverse
  end

  def self.query_group_messages(limit, start_at, group_id)
    group = Group.find(group_id)

    unless group
      return []
    end

    most_recent_message = group.messages.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_message ? most_recent_message.id + 1 : DEFAULT_START_AT)

    group.messages.where('id < ?', start_at).last(limit).reverse
  end


  def self.query_new_group_messages(start_at, group_id)
    group = Group.find(group_id)

    unless group
      return []
    end

    most_recent_message = group.messages.last

    start_at ||= (most_recent_message ? most_recent_message.id : DEFAULT_START_AT)

    group.messages.where('id > ?', start_at).reverse
  end

  private

  def validate_message_ownership
    if self.friendship.blank? && self.group.blank?
      self.errors.add :base, 'Require friendship_id or group_id.'
    end
  end

end
