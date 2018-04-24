class Share < ApplicationRecord
  validates :post_id, presence: true # TODO: add uniqueness constraint
  validate  :validate_share_ownership

  belongs_to(:recipient, class_name: :User, foreign_key: :recipient_id, primary_key: :id, optional: true)
  belongs_to(:group, class_name: :Group, foreign_key: :group_id, primary_key: :id, optional: true)

  belongs_to(:post, class_name: :Post, foreign_key: :post_id, primary_key: :id)

  private

  def validate_share_ownership
    if self.recipient.blank? && self.group.blank?
      self.errors.add :base, 'Require recipient_id or group_id.'
    end
  end

end
