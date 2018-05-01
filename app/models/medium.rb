class Medium < ApplicationRecord
  VALID_TYPES = ['PHOTO', 'VIDEO']

  validates :owner_id, :url, :medium_type, presence: true
  validates :medium_type, inclusion: { in: VALID_TYPES }
  validate  :validate_media_ownership

  belongs_to(:owner, class_name: :User, foreign_key: :owner_id, primary_key: :id)
  belongs_to(:post, class_name: :Post, foreign_key: :post_id, primary_key: :id, optional: true)
  belongs_to(:message, class_name: :Message, foreign_key: :message_id, primary_key: :id, optional: true)

  private

  def validate_media_ownership
    if self.post.blank? && self.message.blank?
      self.errors.add :base, 'Require post_id or message_id.'
    end
  end
end
