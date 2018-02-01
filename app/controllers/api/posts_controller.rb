class Api::PostsController < ApplicationController
  def get_all_posts
    @requester, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless @requester
      render json: ['Requester not found'], status: 404 and return
    end

    @posts = Post.query_all_posts(params[:limit], params[:start_at])

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

    user = params[:user_id] ? User.find(params[:user_id]) : @requester

    @posts = Post.query_authored_posts(params[:limit], params[:start_at], user)

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

    user = params[:user_id] ? User.find(params[:user_id]) : @requester

    @posts = Post.query_liked_posts(params[:limit], params[:start_at], user)

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

    @posts = Post.query_followed_posts(params[:limit], params[:start_at], @requester)

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
