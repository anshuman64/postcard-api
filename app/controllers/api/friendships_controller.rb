class Api::FriendshipsController < ApplicationController
  def create_friend_request
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end
  end

  def accept_friend_request
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end
  end

  def destroy_friendship
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end
  end
end
