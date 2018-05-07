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
    if params[:post_id] && Message.where('friendship_id = ? and post_id = ?', friendship.id, params[:post_id]).exists?
      render json: ['Post as message already exists'], status: 403 and return
    end

    @message = Message.new({ author_id: @client.id, body: params[:body], post_id: params[:post_id], friendship_id: friendship.id })

    if @message.save
      # Create medium for attached image or video
      if params[:medium]
        medium = Medium.new({ aws_path: params[:medium][:awsPath], mime_type: params[:medium][:mime], height: params[:medium][:height], width: params[:medium][:width], owner_id: @client.id, message_id: @message.id })

        unless medium.save
          render json: medium.errors.full_messages, status: 422 and return
        end
      end

      pusher_message = get_pusher_message(@message, @client.id)
      Pusher.trigger('private-' + params[:recipient_id].to_s, 'receive-message', { client_id:  @client.id, message: pusher_message })

      # Create notification unless it is post as message
      unless params[:post_id]
        create_notification(@client.id, params[:recipient_id], { en: @client[:username] }, get_message_notification_preview(@message), { type: 'receive-message', client_id: @client.id })
      end

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
    if params[:post_id] && Message.where('group_id = ? and post_id = ?', group.id, params[:post_id]).exists?
      render json: ['Post as message already exists'], status: 403 and return
    end

    @message = Message.new({ author_id: @client.id, body: params[:body], post_id: params[:post_id], group_id: group.id })

    if @message.save
      # Create medium for image or video
      if params[:medium]
        medium = Medium.new({ aws_path: params[:medium][:awsPath], mime_type: params[:medium][:mime], height: params[:medium][:height], width: params[:medium][:width], owner_id: @client.id, message_id: @message.id })

        unless medium.save
          render json: medium.errors.full_messages, status: 422 and return
        end
      end

      pusher_message = get_pusher_message(@message, @client.id)
      message_preview = get_message_notification_preview(@message)

      group.groupling_users.where('user_id != ? and firebase_uid IS NOT NULL', @client.id).each do |user|
        title = group[:name].nil? ? @client[:username] : @client[:username] + ' > ' + group[:name]

        if params[:post_id]
          # Set the correct values for is_liked_by_client/is_flagged_by_client if there is a post, but don't create a notification
          pusher_message[:is_liked_by_client] = @message.post.likes.where('user_id = ?', user.id).present?
          pusher_message[:is_flagged_by_client] = @message.post.flags.where('user_id = ?', user.id).present?
        else
          create_notification(@client.id, user.id, { en: title }, message_preview, { type: 'receive-message', group_id: group.id })
        end

        Pusher.trigger('private-' + user.id.to_s, 'receive-message', { group_id: group.id, message:  pusher_message })
      end

      render 'api/messages/show'
    else
      render json: @message.errors.full_messages, status: 422
    end
  end

end
