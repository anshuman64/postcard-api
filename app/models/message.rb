class Message < ApplicationRecord
  validates :author_id, :friendship_id, presence: true
  validate  :validate_message_content

  belongs_to(:author, class_name: :User, foreign_key: :author_id, primary_key: :id)

  belongs_to(:friendship, class_name: :Friendship, foreign_key: :friendship_id, primary_key: :id)

  has_one(:post, class_name: :Post, foreign_key: :post_id, primary_key: :id)

  private

  def validate_message_content
    if self.body.blank? && self.image_url.blank? && self.post_id.blank?
      self.errors.add :base, 'Require post body, image_url, or post_id.'
    end
  end
end
