class Api::PostsController < ApplicationController
  def index
    @posts = Post.all

    render :index
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      render :show
    else
      render json: @post.errors.full_messages, status: 422
    end
  end

  def show
    @post = Post.find(params[:id])

    if @post
      render :show
    else
      render json: ['Not found'], status: 404
    end
  end

  def destroy
    @post = Post.find(params[:id])

    if @post.destroy
      render :show
    else
      render json: ['Not found'], status: 404
    end
  end

  private

  def post_params
    params.require(:post).permit(:body, :author_id)
  end
end
