class Post < ApplicationRecord
  validates :author_id, presence: true

  # TODO: add validation to check for empty body and empty image
  # validate :body_or_image_url
  #
  # def body_or_image_url
  #   if body.blank? && image_url.blank?
  #     render json: ['Unprocessable Entity'], status: 422 and return
  #   end
  # end

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
