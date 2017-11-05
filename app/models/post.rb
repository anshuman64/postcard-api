class Post < ApplicationRecord
  validates :body, :author_id, presence: true

  belongs_to(
    :author,
    class_name:  :User,
    foreign_key: :author_id,
    primary_key: :id
  )

  has_many(
    :likes,
    class_name:  :Like,
    foreign_key: :post_id,
    primary_key: :id,
    dependent:   :destroy
  )
end
