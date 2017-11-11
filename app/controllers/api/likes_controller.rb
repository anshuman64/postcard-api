class Api::LikesController < ApplicationController
  def create
    @like = Like.new(like_params)

    if @like.save
      render :show
    else
      render json: @like.errors.full_messages, status: 422
    end
  end

  def destroy
    @like = Like.find(params[:id])

    if @like.destroy
      render :show
    else
      render json: ['Not found'], status: 404
    end
  end

  private

  def like_params
    params.require(:like).permit(:user_id, :post_id)
  end
end
