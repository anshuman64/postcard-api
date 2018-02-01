class Post < ApplicationRecord
  validates :author_id, presence: true
  validate :body_or_image_url

  # TODO: this can potentially be declared as a class method to save memory
  def body_or_image_url
    if body.blank? and image_url.blank?
      errors.add :base, 'Require post body or image_url'
    end
  end

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

  has_many(
    :flags,
    class_name:  :Flag,
    foreign_key: :post_id,
    primary_key: :id,
    dependent:   :destroy
  )
end
