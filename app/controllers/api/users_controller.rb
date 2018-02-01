class Api::UsersController < ApplicationController
  def find_user
    @user, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    render 'api/users/show'
  end

  def create_user
    firebase_uid, error = decode_token(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    @user = User.new({ phone_number: params[:phone_number], firebase_uid: firebase_uid })

    if @user.save
      render 'api/users/show'
    else
      render json: @user.errors.full_messages, status: 422
    end
  end

  def edit_user
    @user, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error.message], status: error.status and return
    end

    if @user.update(user_params)
      render 'api/users/show'
    else
      render json: @user.errors.full_messages, status: 422
    end
  end

  private

  def user_params
    params.permit(:phone_number, :email, :username, :avatar_url)
  end
end
