class Api::LikesController < ApplicationController
  def create
    @like = Like.new(like_params)

    if @like.save
      render 'api/likes/show'
    else
      render json: @like.errors.full_messages, status: 422
    end
  end

  def destroy
    @like = Like.find_by_user_id_and_post_id(params[:user_id], params[:post_id])

    if @like && @like.destroy
      render 'api/likes/show'
    else
      render json: ['Not found'], status: 404
    end
  end

  private

  def like_params
    params.permit(:user_id, :post_id)
  end
end
