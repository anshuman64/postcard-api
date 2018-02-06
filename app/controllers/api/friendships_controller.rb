class Api::FriendshipsController < ApplicationController
  def get_friends
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @users = Friendship.query_friends(@client)

    render 'api/users/index'
  end

  def get_sent_requests
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @users = Friendship.query_sent_requests(@client)

    render 'api/users/index'
  end

  def get_received_requests
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @users = Friendship.query_received_requests(@client)

    render 'api/users/index'
  end

  def create_friend_request
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    if Friendship.find_friendship(client.id, params[:requestee_id])
      render json: ['Friendship already exists'], status: 403 and return
    end

    @friendship = Friendship.new({ requester_id: client.id, requestee_id: params[:requestee_id] })

    if @friendship.save
      render 'api/friendships/show'
    else
      render json: @friendship.errors.full_messages, status: 422
    end
  end

  def accept_friend_request
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @friendship = Friendship.find_by_requester_id_and_requestee_id(params[:requester_id], client.id)

    unless @friendship
      render json: ['Friendship not found'], status: 404 and return
    end

    if @friendship.update({ status: 'ACCEPTED' })
      render 'api/friendships/show'
    else
      render json: @friendship.errors.full_messages, status: 422
    end
  end

  def destroy_friendship
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @friendship = Friendship.find_friendship(client.id, params[:user_id])

    unless @friendship
      render json: ['Friendship not found'], status: 404 and return
    end

    if @friendship.destroy
      render 'api/friendships/show'
    else
      render json: @friendship.errors.full_messages, status: 422
    end
  end
end
