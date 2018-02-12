class Api::FollowsController < ApplicationController
  def create_follow
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @follow = Follow.new({ followee_id: params[:followee_id], follower_id: client.id })

    if @follow.save
      render 'api/follows/show'
    else
      render json: @follow.errors.full_messages, status: 422
    end
  end

  def destroy_follow
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @follow = Follow.find_by_follower_id_and_followee_id(client.id, params[:followee_id])

    # Follow may not exist if blocking the user
    unless @follow
      return
    end

    if @follow && @follow.destroy
      render 'api/follows/show'
    else
      render json: @follow.errors.full_messages, status: 422
    end
  end
end
