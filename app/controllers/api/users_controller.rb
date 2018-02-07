class Api::UsersController < ApplicationController
  def find_user
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    render 'api/users/show'
  end

  def create_user
    firebase_uid, error = decode_token(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @client = User.new({ phone_number: params[:phone_number], firebase_uid: firebase_uid })

    if @client.save
      render 'api/users/show'
    else
      render json: @client.errors.full_messages, status: 422
    end
  end

  def edit_user
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if @client.update(user_params)
      render 'api/users/show'
    else
      render json: @client.errors.full_messages, status: 422
    end
  end

  private

  def user_params
    params.permit(:phone_number, :email, :username, :avatar_url)
  end
end
