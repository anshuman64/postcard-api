class Post < ApplicationRecord
  DEFAULT_LIMIT    = 10
  DEFAULT_START_AT = 1

  validates :author_id, presence: true
  validate  :validate_post_content

  belongs_to(:author, class_name: :User, foreign_key: :author_id, primary_key: :id)

  has_many(:likes, class_name: :Like, foreign_key: :post_id, primary_key: :id, dependent: :destroy)
  has_many(:likers, through: :likes, source: :user)

  has_many(:flags, class_name: :Flag, foreign_key: :post_id, primary_key: :id, dependent: :destroy)

  has_many(:shares, class_name: :Share, foreign_key: :post_id, primary_key: :id, dependent: :destroy)
  has_many(:share_recipients, through: :shares, source: :recipient)

  has_many(:messages, class_name: :Message, foreign_key: :post_id, primary_key: :id, dependent: :destroy)

  def self.query_public_posts(limit, start_at)
    most_recent_post = Post.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    Post.where('id < ? and is_public = ?', start_at, true).last(limit).reverse
  end

  def self.query_authored_posts(limit, start_at, author, fetch_all)
    most_recent_post = author.posts.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    if fetch_all
      return author.posts.where('id < ?', start_at).last(limit).reverse
    else
      return author.posts.where('id < ? and is_public = ?', start_at, true).last(limit).reverse
    end
  end

  def self.query_liked_posts(limit, start_at, user, fetch_all)
    most_recent_post = user.liked_posts.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    # TODO: figure out how this query works
    if fetch_all
      return user.liked_posts.where('post_id < ?', start_at).last(limit).reverse
    else
      return user.liked_posts.where('post_id < ? and is_public = ?', start_at, true).last(limit).reverse
    end
  end

  def self.query_followed_posts(limit, start_at, user)
    most_recent_post = user.followees.collect{ |followee| followee.posts }.flatten.sort_by{ |post| post.id }.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    user.followees.collect{ |followee| followee.posts.where('is_public = ?', true) }.flatten.find_all{ |post| post.id < start_at.to_i }.sort_by{ |post| post.id }.last(limit).reverse
  end

  def self.query_received_posts(limit, start_at, user)
    most_recent_post = user.received_posts.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    user.received_posts.where('post_id < ?', start_at).last(limit).reverse
  end

  private

  def validate_post_content
    if self.body.blank? && self.image_url.blank?
      self.errors.add :base, 'Require post body or image_url.'
    end
  end
end
