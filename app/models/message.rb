class Message < ApplicationRecord
  validates :body, :author_id, :conversation_id, presence: true

  belongs_to(:author, class_name: :User, foreign_key: :author_id, primary_key: :id)

  belongs_to(:conversation, class_name: :Conversation, foreign_key: :conversation_id, primary_key: :id)
end
