class Message < ApplicationRecord
  DEFAULT_LIMIT    = 20
  DEFAULT_START_AT = 1

  validates :author_id, :friendship_id, presence: true
  validate  :validate_message_content

  belongs_to(:author, class_name: :User, foreign_key: :author_id, primary_key: :id)

  belongs_to(:friendship, class_name: :Friendship, foreign_key: :friendship_id, primary_key: :id)

  belongs_to(:post, class_name: :Post, foreign_key: :post_id, primary_key: :id, optional: true)

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

  private

  def validate_message_content
    if self.body.blank? && self.image_url.blank? && self.post_id.blank?
      self.errors.add :base, 'Require post body, image_url, or post_id.'
    end
  end
end
