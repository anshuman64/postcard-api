class Api::PostsController < ApplicationController
  def get_public_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_public_posts(params[:limit], params[:start_at], @client)

    render 'api/posts/index'
  end

  def get_my_authored_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_authored_posts(params[:limit], params[:start_at], @client, true, @client)

    render 'api/posts/index'
  end

  def get_authored_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    user = User.find(params[:user_id])

    @posts = Post.query_authored_posts(params[:limit], params[:start_at], user, false, @client)

    render 'api/posts/index'
  end

  def get_my_liked_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_liked_posts(params[:limit], params[:start_at], @client, true, @client)

    render 'api/posts/index'
  end

  def get_liked_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    user = User.find(params[:user_id])

    @posts = Post.query_liked_posts(params[:limit], params[:start_at], user, false, @client)

    render 'api/posts/index'
  end

  def get_followed_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_followed_posts(params[:limit], params[:start_at], @client)

    render 'api/posts/index'
  end

  def get_received_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @posts = Post.query_received_posts(params[:limit], params[:start_at], @client)

    render 'api/posts/index'
  end

  def create_post
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    is_public = params[:is_public] || false

    @post = Post.new({ author_id: @client.id, body: params[:body], image_url: params[:image_url], is_public: is_public })

    if @post.save
      pusher_user_ids = []
      sms_user_phone_numbers = []

      if params[:recipient_ids]
        pusher_user_ids += params[:recipient_ids]

        params[:recipient_ids].each do |recipient_id|
          create_share(@post.id, recipient_id, nil)
          next
        end
      end

      if params[:group_ids]
        params[:group_ids].each do |group_id|
          create_share(@post.id, nil, group_id)
          groupling_users = Group.find(group_id).groupling_users
          pusher_user_ids += groupling_users.pluck(:id)
          sms_user_phone_numbers += groupling_users.where('firebase_uid IS NULL').pluck(:phone_number)
          next
        end
      end

      # Don't add to pusher_user_ids because they don't need pusher events
      if params[:contact_phone_numbers]
        sms_user_phone_numbers += params[:contact_phone_numbers]

        params[:contact_phone_numbers].each do |phone_number|
          contact_user, contact_error = find_or_create_contact_user(@client.id, phone_number)

          if contact_user
            create_share(@post.id, contact_user.id, nil)
            next
          else
            render json: [contact_error], status: 422 and return
          end

        end
      end

      # Create Twilio SMS
      twilio_post_preview = "User \"" + @client.username + "\" sent you a post on Postcard!:"
      twilio_post_preview += "\n\n\"" + params[:body] + "\"" if params[:body]
      twilio_post_preview += "\n\n[Image attached]" if params[:image_url]
      twilio_post_preview += "\n\n--\nDownload now: http://www.insiya.io/"

      sms_user_phone_numbers.uniq.each do |phone_number|
        send_twilio_sms(phone_number, twilio_post_preview)
      end

      # Create pusher_post
      pusher_post = @post.as_json
      pusher_post[:num_likes] = @post.likes.count
      pusher_post[:num_flags] = @post.flags.count
      user_recipient_ids = @post.user_recipients.ids
      pusher_post[:user_recipient_ids] = user_recipient_ids
      group_recipient_ids = @post.group_recipients.ids
      pusher_post[:group_recipient_ids] = group_recipient_ids
      pusher_post[:author] = @post.author.as_json

      pusher_user_ids.uniq.each do |user_id|
        unless user_id == @client.id
          user = User.find(user_id) # TODO: speed this up
          pusher_post[:is_liked_by_client] = @post.likes.where('user_id = ?', user.id).present?
          pusher_post[:is_flagged_by_client] = @post.flags.where('user_id = ?', user.id).present?
          pusher_post[:user_ids_with_client] = user_recipient_ids & [user.id]
          pusher_post[:group_ids_with_client] = group_recipient_ids & user.groups.ids
          pusher_post[:author][:is_user_followed_by_client] = @post.author.followers.where('follower_id = ?', user.id).present?

          create_notification(@client.id, user_id, nil, @client.username + ' shared a post!', { type: 'receive-post' })
          Pusher.trigger('private-' + user_id.to_s, 'receive-post', {
            user_id: user_id,
            post:    pusher_post
          })
        end
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
