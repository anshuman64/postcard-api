class Api::PostsController < ApplicationController
  def get_all_posts
    requester = decode_token_and_find_user(request.headers['Authorization'])

    unless requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    limit    = params[:limit]     || 10
    start_at = params[:start_at]  || Post.count

    @posts = Post.where('id < ?', start_at).last(limit).reverse

    render 'api/posts/index'
  end

  def get_authored_posts
    requester = decode_token_and_find_user(request.headers['Authorization'])

    unless requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    limit    = params[:limit]     || 10
    start_at = params[:start_at]  || requester.posts.count

    @posts = requester.posts.where('id < ?', start_at).last(limit).reverse

    render 'api/posts/index'
  end

  def get_liked_posts
    requester = decode_token_and_find_user(request.headers['Authorization'])

    unless requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    limit    = params[:limit]     || 10
    start_at = params[:start_at]  || requester.liked_posts.count

    @posts = requester.liked_posts.where('post_id < ?', start_at).last(limit).reverse

    render 'api/posts/index'
  end

  def create_post
    requester = decode_token_and_find_user(request.headers['Authorization'])

    unless requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    @post = Post.new({ body: params[:body], author_id: requester.id })

    if @post.save
      render 'api/posts/show'
    else
      render json: @post.errors.full_messages, status: 422
    end
  end

  def destroy_post
    requester = decode_token_and_find_user(request.headers['Authorization'])

    unless requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    @post = Post.find(params[:id])

    unless @post
      render json: ['Not found'], status: 404 and return
    end

    unless @post.author == requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    if @post.destroy
      render 'api/posts/show'
    else
      render json: @post.errors.full_messages, status: 422
    end
  end
end
