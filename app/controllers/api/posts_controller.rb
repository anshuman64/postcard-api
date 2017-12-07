class Api::PostsController < ApplicationController
  def index
    requester = decode_token_and_find_user(params[:firebase_jwt])

    unless requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    @posts = Post.all

    render 'api/posts/index'
  end

  def create
    requester = decode_token_and_find_user(params[:firebase_jwt])

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

  def destroy
    requester = decode_token_and_find_user(params[:firebase_jwt])

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
      render json: ['Not found'], status: 404
    end
  end
end
