class Api::PostsController < ApplicationController
  def get_all_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @posts = Post.query_all_posts(params[:limit], params[:start_at])

    render 'api/posts/index'
  end

  def get_authored_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    user = params[:user_id] ? User.find(params[:user_id]) : @client

    @posts = Post.query_authored_posts(params[:limit], params[:start_at], user)

    render 'api/posts/index'
  end

  def get_liked_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    user = params[:user_id] ? User.find(params[:user_id]) : @client

    @posts = Post.query_liked_posts(params[:limit], params[:start_at], user)

    render 'api/posts/index'
  end

  def get_followed_posts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @posts = Post.query_followed_posts(params[:limit], params[:start_at], @client)

    render 'api/posts/index'
  end

  def create_post
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @post = Post.new({ author_id: @client.id, body: params[:body], image_url: params[:image_url], is_public: params[:is_public] })

    if @post.save
      if params[:recipient_ids]
        params[:recipient_ids].each do |recipient_id|
          share = Share.new({ post_id: @post.id, recipient_id: recipient_id })

          if share.save
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
      render json: [error.message], status: error.status and return
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
