class Api::MessagesController < ApplicationController
  def get_direct_messages
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if params[:is_new]
      @messages = Message.query_new_direct_messages(params[:start_at], @client.id, params[:user_id])
    else
      @messages = Message.query_direct_messages(params[:limit], params[:start_at], @client.id, params[:user_id])
    end

    render 'api/messages/index'
  end

  def get_group_messages
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if params[:is_new]
      @messages = Message.query_new_group_messages(params[:start_at], params[:group_id])
    else
      @messages = Message.query_group_messages(params[:limit], params[:start_at], params[:group_id])
    end

    render 'api/messages/index'
  end

  def create_direct_message
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    friendship = Friendship.find_friendship(@client.id, params[:recipient_id])

    unless friendship
      render json: ['Friendship not found'], status: 404 and return
    end

    # If message in the same convo with the same post exists, don't recreate it
    if Message.where('author_id = ? and friendship_id = ? and post_id = ?', @client.id, friendship.id, params[:post_id]).exists?
      render json: ['Post as message already exists'], status: 403 and return
    end

    @message = Message.new({ author_id: @client.id, body: params[:body], image_url: params[:image_url], post_id: params[:post_id], friendship_id: friendship.id })

    if @message.save
      if @message.body
        message_preview = @message.body
      elsif @message.post_id
        message_preview = 'Clicked on your post.'
      else
        message_preview = 'Sent you an image.'
      end

      user_id = params[:recipient_id]
      create_notification(@client.id, user_id, { en: @client[:username] }, message_preview, { type: 'receive-message', client_id: @client.id })
      Pusher.trigger('private-' + user_id.to_s, 'receive-message', {
        client_id:  @client.id,
        message: @message
      })

      render 'api/messages/show'
    else
      render json: @message.errors.full_messages, status: 422
    end
  end

  def create_group_message
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    group = Group.find(params[:recipient_id])

    unless group
      render json: ['Group not found'], status: 404 and return
    end

    # If message in the same convo with the same post exists, don't recreate it
    # if Message.where('author_id = ? and friendship_id = ? and post_id = ?', @client.id, friendship.id, params[:post_id]).exists?
    #   render json: ['Post as message already exists'], status: 403 and return
    # end

    @message = Message.new({ author_id: @client.id, body: params[:body], image_url: params[:image_url], post_id: params[:post_id], group_id: group.id })

    if @message.save
      if @message.body
        message_preview = @message.body
      elsif @message.post_id
        message_preview = 'Clicked on your post.'
      else
        message_preview = 'Sent an image.'
      end

      group.groupling_users.where('user_id != ?', @client.id).each do |user|
        title = group[:name].nil? ? @client[:username] : @client[:username] + ' > ' + group[:name]
        create_notification(@client.id, user.id, { en: title }, message_preview, { type: 'receive-message', group_id: group.id })
        Pusher.trigger('private-' + user.id.to_s, 'receive-message', {
          group_id:  group.id,
          message: @message
        })
      end

      render 'api/messages/show'
    else
      render json: @message.errors.full_messages, status: 422
    end
  end

end
