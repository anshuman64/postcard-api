class Api::PostsController < ApplicationController
  def get_received_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_received_posts(params[:limit], params[:start_at], @client)

    render 'api/posts/index'
  end

  def get_client_authored_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_client_authored_posts(params[:limit], params[:start_at], @client)

    render 'api/posts/index'
  end

  def get_user_authored_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    user = User.find(params[:user_id])

    @posts = Post.query_user_authored_posts(params[:limit], params[:start_at], @client, user)

    render 'api/posts/index'
  end

  def get_client_liked_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_client_liked_posts(params[:limit], params[:start_at], @client)

    render 'api/posts/index'
  end

  #### BACKWARDS COMPATABILITY: START ####
  def get_user_liked_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    user = User.find(params[:user_id])

    @posts = Post.query_user_liked_posts(params[:limit], params[:start_at], @client, user)

    render 'api/posts/index'
  end
  #### BACKWARDS COMPATABILITY: END ####

  def create_post
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if params[:post_id]
      original_post = Post.find(params[:post_id])

      unless original_post
        render json: ['Post not found'], status: 404 and return
      end

      @post = Post.new({ author_id: @client.id, body: original_post[:body] })
    else
      @post = Post.new({ author_id: @client.id, body: params[:body] })
    end

    if @post.save
      pusher_user_ids = []
      sms_user_phone_numbers = []

      # Create shares for single recipients
      if params[:recipient_ids]
        pusher_user_ids += params[:recipient_ids]

        params[:recipient_ids].each do |recipient_id|
          share = Share.new({ post_id: @post.id, recipient_id: recipient_id })

          unless share.save
            render json: share.errors.full_messages, status: 422 and return
          end

          next
        end
      end

      # Create shares for groups
      if params[:group_ids]
        params[:group_ids].each do |group_id|
          share = Share.new({ post_id: @post.id, group_id: group_id })

          unless share.save
            render json: share.errors.full_messages, status: 422 and return
          end

          groupling_users = Group.find(group_id).groupling_users
          pusher_user_ids += groupling_users.pluck(:id)
          sms_user_phone_numbers += groupling_users.where('firebase_uid IS NULL').pluck(:phone_number)
          next
        end
      end

      # Create shares for contacts
      # Don't add to pusher_user_ids because they don't need pusher events
      if params[:contact_phone_numbers]
        sms_user_phone_numbers += params[:contact_phone_numbers]

        params[:contact_phone_numbers].each do |phone_number|
          contact_user, contact_error = find_or_create_contact_user(@client.id, phone_number)

          if contact_user
            share = Share.new({ post_id: @post.id, recipient_id: contact_user.id })

            unless share.save
              render json: share.errors.full_messages, status: 422 and return
            end

            next
          else
            render json: [contact_error], status: 422 and return
          end

        end
      end

      # Create media for photos and videos
      if params[:media]
        params[:media].each do |medium_object|
          medium = Medium.new({ aws_path: medium_object[:awsPath], mime_type: medium_object[:mime], height: medium_object[:height], width: medium_object[:width], owner_id: @client.id, post_id: @post.id })

          unless medium.save
            render json: medium.errors.full_messages, status: 422 and return
          end

          next
        end
      elsif original_post && original_post.media
        original_post.media.each do |medium_object|
          medium = Medium.new({ aws_path: medium_object[:aws_path], mime_type: medium_object[:mime_type], height: medium_object[:height], width: medium_object[:width], owner_id: @client.id, post_id: @post.id })

          unless medium.save
            render json: medium.errors.full_messages, status: 422 and return
          end

          next
        end
      end

      # Create Twilio SMS
      twilio_post_preview = get_sms_start_string(@client) + " sent you a post on Postcard!:"
      twilio_post_preview += "\n\n\"" + @post[:body] + "\"" if @post[:body]
      twilio_post_preview += "\n\n[Media attached]" if !@post.media.empty?
      twilio_post_preview += "\n\n-- Download Now --\nhttps://postcard.insiya.io/?utm_source=app&utm_term=post"

      sms_user_phone_numbers.uniq.each do |phone_number|
        send_twilio_sms(phone_number, twilio_post_preview)
      end

      # Create pusher_post
      pusher_post = @post.as_json
      pusher_post[:num_likes] = @post.likes.count
      pusher_post[:num_flags] = @post.flags.count
      pusher_post[:media]     = @post.media
      user_recipient_ids = @post.user_recipients.ids
      pusher_post[:user_recipient_ids] = user_recipient_ids
      group_recipient_ids = @post.group_recipients.ids
      pusher_post[:group_recipient_ids] = group_recipient_ids
      pusher_post[:author] = @post.author.as_json

      User.where('id IN (?) and id != ?', pusher_user_ids.uniq, @client.id).each do |user|
        pusher_post[:is_liked_by_client] = @post.likes.where('user_id = ?', user.id).present?
        pusher_post[:is_flagged_by_client] = @post.flags.where('user_id = ?', user.id).present?
        pusher_post[:user_ids_with_client] = user_recipient_ids & [user.id]
        pusher_post[:group_ids_with_client] = group_recipient_ids & user.groups.ids

        create_notification(@client.id, user.id, nil, @client.username + ' shared a post!', { type: 'receive-post' })
        Pusher.trigger('private-' + user.id.to_s, 'receive-post', {
          user_id: user.id,
          post:    pusher_post
        })
      end

      render 'api/posts/show'
    else
      render json: @post.errors.full_messages, status: 422
    end
  end

  def destroy_post
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @post = Post.find(params[:id])

    unless @post
      render json: ['Post not found'], status: 404 and return
    end

    unless @post.author == @client
      render json: ['Unauthorized request'], status: 403 and return
    end

    if @post.destroy
      render 'api/posts/show'
    else
      render json: @post.errors.full_messages, status: 422
    end
  end

end
