class Circling < ApplicationRecord
  validates :circle_id, presence: true # TODO: add uniqueness validation
  validate :validate_circling_recipient

  belongs_to(:user, class_name: :User, foreign_key: :user_id, primary_key: :id, optional: true)
  belongs_to(:group, class_name: :Group, foreign_key: :group_id, primary_key: :id, optional: true)

  belongs_to(:circle, class_name: :Circle, foreign_key: :circle_id, primary_key: :id)

  private

  def validate_circling_recipient
    if self.user_id.blank? && self.group_id.blank?
      self.errors.add :base, 'Require user_id or group_id.'
    end
  end
end
