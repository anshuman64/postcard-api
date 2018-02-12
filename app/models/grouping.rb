class Grouping < ApplicationRecord
  validates :participant_id, :conversation_id, presence: true

  belongs_to(:conversation, class_name: :Conversation, foreign_key: :conversation_id, primary_key: :id)

  belongs_to(:participant, class_name: :User, foreign_key: :participant_id, primary_key: :id)
end
