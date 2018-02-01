class Api::FollowsController < ApplicationController
  def create_follow
    requester, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @follow = Follow.new({ followee_id: params[:followee_id], follower_id: requester.id })

    if @follow.save
      render 'api/follows/show'
    else
      render json: @follow.errors.full_messages, status: 422
    end
  end

  def destroy_follow
    requester, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @follow = Follow.find_by_follower_id_and_followee_id(requester.id, params[:followee_id])

    unless @follow
      render json: ['Follow not found'], status: 404 and return
    end

    unless @follow.follower == requester
      render json: ['Unauthorized request'], status: 403 and return
    end

    if @follow.destroy
      render 'api/follows/show'
    else
      render json: @follow.errors.full_messages, status: 422
    end
  end
end
