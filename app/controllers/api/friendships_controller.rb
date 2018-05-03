class Api::FriendshipsController < ApplicationController
  def get_friends
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @users = Friendship.query_friends(@client)

    render 'api/users/index'
  end

  def get_sent_requests
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @users = Friendship.query_sent_requests(@client)

    render 'api/users/index'
  end

  def get_received_requests
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @users = Friendship.query_received_requests(@client)

    render 'api/users/index'
  end

  def get_friends_from_contacts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @users = Friendship.query_friends_from_contacts(@client, params[:contacts])

    # TODO: make this better. Currently sends notification to client's contacts, not user's
    if params[:is_first_login]
      @users.ids.each do |user_id|
        create_notification(@client.id, user_id, nil, 'One of your friends joined Postcard!', { type: 'welcome-contact' })
      end
    end

    render 'api/users/index'
  end

  def create_friend_request
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    user_id = params[:user_id]

    # TODO: make "friend by username" a different endpoint
    if params[:username]
      user = User.find_by_username(params[:username])

      unless user
        render json: ['User not found'], status: 404 and return
      end

      if user.id == client.id
        render json: ['Requester and requestee cannot be the same'], status: 403 and return
      end

      user_id = user.id
    end

    if Friendship.find_friendship(client.id, user_id)
      render json: ['Friendship already exists'], status: 403 and return
    end

    # Return error if requestee has blocked the requester
    is_client_blocked_by_user = Block.find_by_blocker_id_and_blockee_id(user_id, client.id).present?
    if is_client_blocked_by_user
      render json: ['Requester blocked by requestee'], status: 403 and return
    end

    # Return error if requester has blocked the requestee
    is_client_blocked_by_user = Block.find_by_blocker_id_and_blockee_id(client.id, user_id).present?
    if is_client_blocked_by_user
      render json: ['Requestee blocked by requester'], status: 403 and return
    end

    @friendship = Friendship.new({ requester_id: client.id, requestee_id: user_id })
    if @friendship.save
      # Send event to client with user info if user added by username
      if params[:username]
        Pusher.trigger('private-' + client.id.to_s, 'create-friendship', { user: user })
      end

      # Send event to requestee
      create_notification(client.id, user_id, nil, client.username + ' sent you a friend request.', { type: 'receive-friendship' })
      Pusher.trigger('private-' + user_id.to_s, 'receive-friendship', { client: client })

      render 'api/friendships/show'
    else
      render json: @friendship.errors.full_messages, status: 422
    end
  end

  def accept_friend_request
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @friendship = Friendship.find_by_requester_id_and_requestee_id(params[:user_id], client.id)

    unless @friendship
      render json: ['Friendship not found'], status: 404 and return
    end

    if @friendship.update({ status: 'ACCEPTED' })
      create_notification(client.id, params[:user_id], nil, client.username + ' accepted your friend request.', { type: 'receive-accepted-friendship' })
      Pusher.trigger('private-' + params[:user_id].to_s, 'receive-accepted-friendship', { client: client })

      render 'api/friendships/show'
    else
      render json: @friendship.errors.full_messages, status: 422
    end
  end

  def destroy_friendship
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @friendship = Friendship.find_friendship(client.id, params[:user_id])

    # Friendship may not exist if blocking the user
    unless @friendship
      render json: {} and return
    end

    if @friendship.destroy
      Pusher.trigger('private-' + params[:user_id].to_s, 'destroy-friendship', { friendship: @friendship })

      render 'api/friendships/show'
    else
      render json: @friendship.errors.full_messages, status: 422
    end
  end

end
