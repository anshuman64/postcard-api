class Api::UsersController < ApplicationController
  def find_user
    @user, error = decode_token_and_find_user(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    if @user
      render 'api/users/show'
    else
      render json: ['Unauthorized request'], status: 403 and return
    end
  end

  def create_user
    firebase_uid, error = decode_token(request.headers['Authorization'])

    unless error.nil?
      render json: [error], status: 401 and return
    end

    unless firebase_uid
      render json: ['Invalid JWT'], status: 403 and return
    end

    @user = User.new({ phone_number: params[:phone_number], firebase_uid: firebase_uid })

    if @user.save
      render 'api/users/show'
    else
      render json: @user.errors.full_messages, status: 422
    end
  end
end
