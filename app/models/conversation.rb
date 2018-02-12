class Conversation < ApplicationRecord
  has_many(:messages, class_name: :Message, foreign_key: :author_id, primary_key: :id, dependent: :destroy)

  has_many(:groupings, class_name: :Grouping, foreign_key: :conversation_id, primary_key: :id, dependent: :destroy)
  has_many(:participants, through: :groupings, source: :participant)
end
