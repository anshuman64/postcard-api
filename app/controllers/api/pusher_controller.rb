class Api::PusherController < ApplicationController
  def auth
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    authorized_channel = 'private-' + client.id.to_s

    if authorized_channel == params[:channel_name]
      response = Pusher.authenticate(params[:channel_name], params[:socket_id])
      render json: response
    else
      render json: ['Unauthorized request to Pusher'], status: '403'
    end
  end
end
