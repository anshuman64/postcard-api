class Post < ApplicationRecord
  DEFAULT_LIMIT    = 10
  DEFAULT_START_AT = 1

  validates :author_id, presence: true

  belongs_to(:author, class_name: :User, foreign_key: :author_id, primary_key: :id)

  has_many(:likes, class_name: :Like, foreign_key: :post_id, primary_key: :id, dependent: :destroy)
  has_many(:likers, through: :likes, source: :user)

  has_many(:flags, class_name: :Flag, foreign_key: :post_id, primary_key: :id, dependent: :destroy)

  has_many(:shares, class_name: :Share, foreign_key: :post_id, primary_key: :id, dependent: :destroy)
  has_many(:user_recipients, through: :shares, source: :recipient)
  has_many(:group_recipients, through: :shares, source: :group)

  has_many(:messages, class_name: :Message, foreign_key: :post_id, primary_key: :id, dependent: :destroy)

  has_many(:media, class_name: :Medium, foreign_key: :post_id, primary_key: :id, dependent: :destroy)

  def self.query_received_posts(limit, start_at, client)
    posts_array = client.received_posts.ids + client.received_posts_from_groups.where('author_id != ?', client.id).ids

    limit    ||= DEFAULT_LIMIT
    start_at ||= (posts_array.empty? ? DEFAULT_START_AT : posts_array.max + 1)

    flagged_post_ids = client.flagged_posts.ids.count > 0 ? client.flagged_posts.ids : 0
    blocked_user_post_ids = client.blockees.ids.count > 0 ? client.blockees.ids : 0

    Post.where('id < ? and id IN (?) and id NOT IN (?) and author_id NOT IN (?)', start_at, posts_array, flagged_post_ids, blocked_user_post_ids).last(limit).reverse
  end

  def self.query_client_authored_posts(limit, start_at, client)
    most_recent_post = client.posts.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    flagged_post_ids = client.flagged_posts.ids.count > 0 ? client.flagged_posts.ids : 0

    return client.posts.where('id < ? and id NOT IN (?)', start_at, flagged_post_ids).last(limit).reverse
  end

  def self.query_client_liked_posts(limit, start_at, client)
    most_recent_post = client.liked_posts.last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    flagged_post_ids = client.flagged_posts.ids.count > 0 ? client.flagged_posts.ids : 0
    blocked_user_post_ids = client.blockees.ids.count > 0 ? client.blockees.ids : 0

    # TODO: figure out how this query works
    return client.liked_posts.where('post_id < ? and post_id NOT IN (?) and author_id NOT IN (?)', start_at, flagged_post_ids, blocked_user_post_ids).last(limit).reverse
  end

  def self.query_user_authored_posts(limit, start_at, client, user)
    if user.blockers.where('blocker_id = ?', client.id).present?
      return []
    end

    posts_array = client.received_posts.where('author_id = ?', user.id).ids + client.received_posts_from_groups.where('author_id = ?', user.id).ids

    limit    ||= DEFAULT_LIMIT
    start_at ||= (posts_array.empty? ? DEFAULT_START_AT : posts_array.max + 1)

    flagged_post_ids = client.flagged_posts.ids.count > 0 ? client.flagged_posts.ids : 0

    Post.where('id < ? and id IN (?) and id NOT IN (?)', start_at, posts_array, flagged_post_ids).last(limit).reverse
  end

  #### BACKWARDS COMPATABILITY: START ####
  def self.query_user_liked_posts(limit, start_at, client, user)
    if user.blockers.where('blocker_id = ?', client.id).present?
      return []
    end

    most_recent_post = user.liked_posts.where('author_id = ?', client.id).last

    limit    ||= DEFAULT_LIMIT
    start_at ||= (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    flagged_post_ids = client.flagged_posts.ids.count > 0 ? client.flagged_posts.ids : 0

    return user.liked_posts.where('post_id < ? and (author_id = ?) and post_id NOT IN (?)', start_at, client.id, flagged_post_ids).last(limit).reverse
  end
  #### BACKWARDS COMPATABILITY: END ####

end
