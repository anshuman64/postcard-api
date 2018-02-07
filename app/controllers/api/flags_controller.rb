class Api::FlagsController < ApplicationController
  def create_flag
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @flag = Flag.new({ post_id: params[:post_id], user_id: client.id })

    if @flag.save
      render 'api/flags/show'
    else
      render json: @flag.errors.full_messages, status: 422
    end
  end

  def destroy_flag
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @flag = Flag.find_by_user_id_and_post_id(client.id, params[:post_id])

    unless @flag
      render json: ['Flag not found'], status: 404 and return
    end

    if @flag.destroy
      render 'api/flags/show'
    else
      render json: @flag.errors.full_messages, status: 422
    end
  end
end
