class User < ApplicationRecord
  validates :phone_number, :firebase_uid, presence: true
  validates :phone_number, uniqueness: true

  has_many(
    :posts,
    class_name:  :Post,
    foreign_key: :author_id,
    primary_key: :id,
    dependent:   :destroy
  )

  has_many(
    :likes,
    class_name:  :Like,
    foreign_key: :user_id,
    primary_key: :id,
    dependent:   :destroy
  )
end
