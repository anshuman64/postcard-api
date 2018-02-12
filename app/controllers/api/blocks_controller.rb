class Api::BlocksController < ApplicationController
  def get_blocked_users
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @users = @client.blockees

    render 'api/users/index'
  end

  def create_block
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @block = Block.new({ blockee_id: params[:blockee_id], blocker_id: client.id })

    if @block.save
      render 'api/blocks/show'
    else
      render json: @block.errors.full_messages, status: 422
    end
  end

  def destroy_block
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @block = Block.find_by_blocker_id_and_blockee_id(client.id, params[:blockee_id])

    unless @block
      render json: ['Block not found'], status: 404 and return
    end

    if @block.destroy
      render 'api/blocks/show'
    else
      render json: @block.errors.full_messages, status: 422
    end
  end
end
