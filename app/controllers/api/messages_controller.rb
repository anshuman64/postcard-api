class Api::MessagesController < ApplicationController
  def get_direct_messages
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @messages = Message.query_direct_messages(params[:limit], params[:start_at], client.id, params[:user_id])

    render 'api/messages/index'
  end

  def get_group_messages
    # TODO: This method is here when we add support for group message threads
    # It is here right now just to make it easy to pick up when we start that project
  end

  def create_message
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    friendship = Friendship.find_friendship(client.id, params[:recipient_id])

    unless friendship
      render json: ['Friendship not found'], status: 404 and return
    end

    @message = Message.new({ author_id: client.id, body: params[:body], friendship_id: friendship.id })

    if params[:post_id]
      @message.post_id = params[:post_id]
    end

    if @message.save
      render 'api/messages/show'
    else
      render json: @message.errors.full_messages, status: 422
    end
  end
end
