class Api::PostsController < ApplicationController
  DEFAULT_LIMIT    = 10
  DEFAULT_START_AT = 1

  def get_all_posts
    @requester, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless @requester
      render json: ['Requester not found'], status: 404 and return
    end

    most_recent_post = Post.last

    limit    = params[:limit]    || DEFAULT_LIMIT
    start_at = params[:start_at] || (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    @posts = Post.where('id < ?', start_at).last(limit).reverse

    render 'api/posts/index'
  end

  def get_authored_posts
    @requester, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless @requester
      render json: ['Requester not found'], status: 404 and return
    end

    if params[:user_id]
      user = User.find(params[:user_id])
    else
      user = @requester
    end

    most_recent_post = user.posts.last

    limit    = params[:limit]    || DEFAULT_LIMIT
    start_at = params[:start_at] || (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    @posts = user.posts.where('id < ?', start_at).last(limit).reverse

    render 'api/posts/index'
  end

  def get_liked_posts
    @requester, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless @requester
      render json: ['Requester not found'], status: 404 and return
    end

    # Need to add proper error handling if user does not exist
    if params[:user_id]
      user = User.find(params[:user_id])
    else
      user = @requester
    end

    most_recent_post = user.liked_posts.last

    limit    = params[:limit]    || DEFAULT_LIMIT
    start_at = params[:start_at] || (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    @posts = user.liked_posts.where('post_id < ?', start_at).last(limit).reverse

    render 'api/posts/index'
  end

  def get_followed_posts
    @requester, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless @requester
      render json: ['Requester not found'], status: 404 and return
    end

    most_recent_post = @requester.followees.collect{|u| u.posts}.flatten.last

    limit    = params[:limit]    || DEFAULT_LIMIT
    start_at = params[:start_at] || (most_recent_post ? most_recent_post.id + 1 : DEFAULT_START_AT)

    @posts = @requester.followees.collect{|u| u.posts.where('id < ?', start_at).last(limit)}.flatten.last(limit).reverse

    render 'api/posts/index'
  end

  def create_post
    @requester, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless @requester
      render json: ['Requester not found'], status: 404 and return
    end

    @post = Post.new({ body: params[:body], author_id: @requester.id, image_url: params[:image_url] })

    if @post.save
      render 'api/posts/show'
    else
      render json: @post.errors.full_messages, status: 422
    end
  end

  def destroy_post
    @requester, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless @requester
      render json: ['Requester not found'], status: 404 and return
    end

    @post = Post.find(params[:id])

    unless @post
      render json: ['Post not found'], status: 404 and return
    end

    unless @post.author == @requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    if @post.destroy
      render 'api/posts/show'
    else
      render json: @post.errors.full_messages, status: 422
    end
  end
end
