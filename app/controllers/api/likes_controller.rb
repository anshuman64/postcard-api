class Api::LikesController < ApplicationController
  def create_like
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @like = Like.new({ post_id: params[:post_id], user_id: client.id })

    if @like.save
      render 'api/likes/show'
    else
      render json: @like.errors.full_messages, status: 422
    end
  end

  def destroy_like
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @like = Like.find_by_user_id_and_post_id(client.id, params[:post_id])

    unless @like
      render json: ['Like not found'], status: 404 and return
    end

    unless @like.user == client
      render json: ['Unauthorized request'], status: 403 and return
    end

    if @like.destroy
      render 'api/likes/show'
    else
      render json: @like.errors.full_messages, status: 422
    end
  end
end
