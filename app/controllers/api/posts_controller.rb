class Api::PostsController < ApplicationController
  def index
    @posts = Post.all

    render 'api/posts/index'
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      render 'api/posts/show'
    else
      render json: @post.errors.full_messages, status: 422
    end
  end

  def destroy
    @post = Post.find(params[:id])

    if @post.destroy
      render 'api/posts/show'
    else
      render json: ['Not found'], status: 404
    end
  end

  private

  def post_params
    params.permit(:body, :author_id)
  end
end
