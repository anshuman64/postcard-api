class Api::UsersController < ApplicationController
  def create
    firebase_uid = decode_token(params[:firebase_jwt])

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
