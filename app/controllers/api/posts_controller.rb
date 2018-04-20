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

  # TODO: get posts from groups
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
      if params[:recipient_ids]
        params[:recipient_ids].each do |recipient_id|
          # Create share for each recipient
          share = Share.new({ post_id: @post.id, recipient_id: recipient_id })

          if share.save
            # Create push notification for each recipient
            user = User.find(recipient_id)
            create_notification(user, @client.username + ' shared a post with you!', { type: 'receive-post', client: @client, user: user, post: @post, message: @message })
            Pusher.trigger('private-' + user.id.to_s, 'receive-post', {
              client:  @client,
              user:    user,
              post:    @post
            })

            next
          else
            render json: ['Sharing posts failed.'], status: 422 and return
          end
        end
      end

      if params[:group_ids]
        params[:group_ids].each do |group_id|
          # Create share for each recipient
          puts group_id
          share = Share.new({ post_id: @post.id, group_id: group_id })

          if share.save
            # Create push notification for each recipient
            # user = User.find(recipient_id)
            # create_notification(user, @client.username + ' shared a post with you!', { type: 'receive-post', client: @client, user: user, post: @post, message: @message })
            # Pusher.trigger('private-' + user.id.to_s, 'receive-post', {
            #   client:  @client,
            #   user:    user,
            #   post:    @post
            # })

            next
          else
            render json: ['Sharing posts failed.'], status: 422 and return
          end
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
